# Solution Design

## Highlevel

- review the code and fingure out what is already employed
- implement the 3 layers of monitoring - as below
- add instrumentation to enrich the application performance monitoring
- suggestions for improvement of deployment mechanisms etc
- further development

### 3 layers of monitoring

1. cluster - Cloudwatch metrics
1. container - AWS (cloudwatch) logs
1. application - APM?

## Delivery

What has been done:

- the reuse of common variables to increase reusability of the code. (perhaps this would be better suited as a module rather than defined as part of the application.) implemented common_tags and the local.name var
- i can see that awslogs is being implemented as part of the deployment, which is good.
- also, the use of fargate automatically implements the available cloudwatch metrics on the cluster. also good.
- enabling container insights. the code for this is obscure because we might not want to enable insights for all containers, just ones we're interested in - like in prod or pre-prod and not dev or sandbox. the terraform module needs rewriting so that we can accomodate different use cases for different environments. for now we default to true so that it is enabled for all deployments.
- the provider version is forced to ensure the container insights feature. there doesn't look like anything will break. (as-if hello world could break!)
- there's no remote state, which is bad, but for the purpose of this test we'll stick with the local statefile.
- the iam roles have generic names so there's overlapping scope if/when applications are deployed to the same account. adding the local.name to the names of the roles.
- fixed the deploy script. issue with the region switch in the docker login command.

What's next:

- create cloudwatch alarms to help monitor the application containers and ecs cluster - we need to employ an SNS queue to received these alarms.
- find a good APM to help monitor application performance
