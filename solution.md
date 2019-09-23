# Solution

## Highlevel Design

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

### What has been done

- the reuse of common variables to increase reusability of the code. (perhaps this would be better suited as a module rather than defined as part of the application.) implemented common_tags and the local.name var
- i can see that awslogs is being implemented as part of the deployment, which is good.
- also, the use of fargate automatically implements the available cloudwatch metrics on the cluster. also good.
- enabling container insights. the code for this is obscure because we might not want to enable insights for all containers, just ones we're interested in - like in prod or pre-prod and not dev or sandbox. the terraform module needs rewriting so that we can accomodate different use cases for different environments. for now we default to true so that it is enabled for all deployments.
- the provider version is forced to ensure the container insights feature. there doesn't look like anything will break. (as-if hello world could break!)
- there's no remote state, which is bad, but for the purpose of this test we'll stick with the local statefile.
- the iam roles have generic names so there's overlapping scope if/when applications are deployed to the same account. adding the local.name to the names of the roles.
- fixed the deploy script. issue with the region switch in the docker login command.
- also fixed the region in the update-service command.
- all above has been tested and working completely. the ALB endpoint provides the intended output "hello world". the container insights show the metrics from the ECS cluster (ie the single container).
- noticed that the app doesn't actually have any logging routines. it'll be hard to introduce logging into the logic of a hello world application because there's no real business logic behind loading that to the screen. we should consider that there are some well know logging frameworks that could be employed. even sacrificing the efficiency of writing code in order to ensure better instrumented code. there are now tools to integrate the logging framework into awslogs, which is already available. winston-cloudwatch is a package that provides this option using well known winston library.

### What's next

- create cloudwatch alarms to help monitor the application containers and ecs cluster
- we need to employ an SNS queue to received these alarms and provide alerting
- logging consolidator - such as splunk or datadog.
- find a good APM to help monitor application performance

## Questions from the task

### Consider how well your solution be applied to other applications and infrastructure?

So far we have enabled container insights. Even though this is quite a new product and the usefulness of it is yet to be seen. However, since all infrastructure within this project is based in AWS, the container insights should be most useful when used alongside Cloudwatch and CW Logs.

This solution might not work so well in a larger implementation. If each application is building it's own infrastructure and subsequent monitoring/alerting, there might be some problems with consolidation of logging and/or metrics. Having applications share these resources might be a better solution - this would require recoding of the terraform so that it calls artifacts from a common statefile.

In addition, better labelling of containers/services would introduce more granular metrics - especially in a common/consolidated monitoring solution.

### Think about proactive vs reactive monitoring, and what the advantages might be of each.

With the monitoring we have enabled, all we have is passive monitoring - we need to go look at the dashboards and logs to see what is happening. If we enable cloudwatch alarms then we can have some reactive monitoring. Having metrics stored over a period of time we can perhaps analyse and create some proactive monitoring, whereby we can assume potential issues with capacity or growth and perform remediation tasks before issues are found. These reactive monitors may create false positive alerts and additional checks might be needed to ensure resources are not wasted.

### How well does it scale? How will it react to adding additional instances of our application, or additional supporting services?

The implementation on Fargate means it will react to load as required. However, this is not the cheapest method of implementation. Perhaps using a container orchestrator such as EKS (or other Kubernetes implementation) would mean applications would not need to manage/maintain their own infrastructure (and more importantly their own terraform) but also the combining and pooling of resources is more cost effective.

The monitoring in this respect should also react to scaling. As containers start and stop the cloudwatch metrics will be received and consolidated into the view. The issue of searching logs might become a problem and a better log consolidator should be considered.

### Documentation is important to us. We have keen eye on how you present the information and how can it be used.

I hope this has been a nice read...

## Future development

1. deploy a common container platform (probably kubernetes) and implement daemonsets or side cars to handle all monitoring and logging without the need to define it within the application project.
1. employ saas providers (managed service) to handle the data (logs and metrics). the data is highly available but also the management of the underlying infrastructure sits with them. the service also provides dashboards and inergrations into downstream alerting services. example is splunk for logging and datadog for metrics integrating into pagerduty for notifications.
