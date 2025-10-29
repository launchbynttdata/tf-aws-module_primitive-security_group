// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package testimpl

import (
        "context"
        "strings"
        "testing"

        "github.com/aws/aws-sdk-go-v2/aws"
        "github.com/aws/aws-sdk-go-v2/config"
        "github.com/aws/aws-sdk-go-v2/service/ec2"
        ec2types "github.com/aws/aws-sdk-go-v2/service/ec2/types"
        "github.com/gruntwork-io/terratest/modules/terraform"
        "github.com/launchbynttdata/lcaf-component-terratest/types"
        "github.com/stretchr/testify/assert"
        "github.com/stretchr/testify/require"
)

const (
        failedToGetSecurityGroupMsg = "Failed to get security group"
        failedToDescribeVPCMsg      = "Failed to describe VPC"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
        ec2Client := GetAWSEC2Client(t)

        // Get outputs using normalized output names
        resourceId := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_id")
        resourceName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_name")

        t.Run("TestSecurityGroupExists", func(t *testing.T) {
                testSecurityGroupExists(t, ec2Client, resourceId, resourceName)
        })

        t.Run("TestSecurityGroupProperties", func(t *testing.T) {
                testSecurityGroupProperties(t, ec2Client, resourceId)
        })

        t.Run("TestSecurityGroupVPCAssociation", func(t *testing.T) {
                testSecurityGroupVPCAssociation(t, ec2Client, resourceId)
        })

        t.Run("TestSecurityGroupTags", func(t *testing.T) {
                testSecurityGroupTags(t, ec2Client, resourceId)
        })
}

func testSecurityGroupExists(t *testing.T, ec2Client *ec2.Client, groupId, expectedName string) {
        securityGroup := getSecurityGroup(t, ec2Client, groupId)

        // Verify security group exists and has expected properties
        assert.NotNil(t, securityGroup, "Security group should exist")
        assert.Equal(t, groupId, *securityGroup.GroupId, "Security group ID should match")

        // Verify the name matches (generic - works with any name)
        if securityGroup.GroupName != nil {
                assert.Equal(t, expectedName, *securityGroup.GroupName, "Security group name should match")
        }
}

func testSecurityGroupProperties(t *testing.T, ec2Client *ec2.Client, groupId string) {
        securityGroup := getSecurityGroup(t, ec2Client, groupId)

        // Generic property checks - validate structure without hardcoding values
        assert.NotNil(t, securityGroup.GroupId, "Security group should have an ID")
        assert.True(t, strings.HasPrefix(*securityGroup.GroupId, "sg-"), "Security group ID should start with 'sg-'")

        assert.NotNil(t, securityGroup.GroupName, "Security group should have a name")
        assert.NotEmpty(t, *securityGroup.GroupName, "Security group name should not be empty")

        assert.NotNil(t, securityGroup.Description, "Security group should have a description")
        assert.NotEmpty(t, *securityGroup.Description, "Security group description should not be empty")

        assert.NotNil(t, securityGroup.OwnerId, "Security group should have an owner ID")
        assert.NotEmpty(t, *securityGroup.OwnerId, "Security group owner ID should not be empty")
}

func testSecurityGroupVPCAssociation(t *testing.T, ec2Client *ec2.Client, groupId string) {
        securityGroup := getSecurityGroup(t, ec2Client, groupId)

        // Verify VPC association
        require.NotNil(t, securityGroup.VpcId, "Security group should be associated with a VPC")
        assert.True(t, strings.HasPrefix(*securityGroup.VpcId, "vpc-"), "VPC ID should start with 'vpc-'")

        // Verify the VPC exists
        vpcInput := &ec2.DescribeVpcsInput{
                VpcIds: []string{*securityGroup.VpcId},
        }

        vpcOutput, err := ec2Client.DescribeVpcs(context.TODO(), vpcInput)
        require.NoError(t, err, failedToDescribeVPCMsg)
        require.Len(t, vpcOutput.Vpcs, 1, "Should find exactly one VPC")

        vpc := vpcOutput.Vpcs[0]
        assert.Equal(t, *securityGroup.VpcId, *vpc.VpcId, "VPC ID should match")
}

func testSecurityGroupTags(t *testing.T, ec2Client *ec2.Client, groupId string) {
        securityGroup := getSecurityGroup(t, ec2Client, groupId)

        // Verify tags exist (generic - don't check specific tag values)
        require.NotNil(t, securityGroup.Tags, "Security group should have tags")
        require.Greater(t, len(securityGroup.Tags), 0, "Security group should have at least one tag")

        // Verify the canonical 'provisioner' tag exists (this is always added by the module)
        foundProvisionerTag := false
        for _, tag := range securityGroup.Tags {
                if *tag.Key == "provisioner" {
                        foundProvisionerTag = true
                        assert.Equal(t, "Terraform", *tag.Value, "Provisioner tag should be 'Terraform'")
                        break
                }
        }
        assert.True(t, foundProvisionerTag, "Security group should have the 'provisioner' tag")
}

func getSecurityGroup(t *testing.T, ec2Client *ec2.Client, groupId string) *ec2types.SecurityGroup {
        input := &ec2.DescribeSecurityGroupsInput{
                GroupIds: []string{groupId},
        }

        result, err := ec2Client.DescribeSecurityGroups(context.TODO(), input)
        require.NoError(t, err, failedToGetSecurityGroupMsg)
        require.Len(t, result.SecurityGroups, 1, "Should find exactly one security group")

        return &result.SecurityGroups[0]
}

func GetAWSEC2Client(t *testing.T) *ec2.Client {
        awsEC2Client := ec2.NewFromConfig(GetAWSConfig(t))
        return awsEC2Client
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
        cfg, err := config.LoadDefaultConfig(context.TODO())
        require.NoErrorf(t, err, "unable to load SDK config, %v", err)
        return cfg
}
