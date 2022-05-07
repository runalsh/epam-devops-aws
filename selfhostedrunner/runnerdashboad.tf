resource "aws_cloudwatch_dashboard" "runner-dashboard" {
  dashboard_name = "runner-dashboard"
  dashboard_body = <<EOF
  {  
    "widgets": [
        {
            "height": 6,
            "width": 4,
            "y": 0,
            "x": 10,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "CWAgent", "disk_used_percent", "InstanceId", "${aws_instance.runner.id}" ]
                ],
                "view": "singleValue",
                "region": "eu-central-1",
                "period": 60,
                "title": "Disk space utilization",
                "stat": "Average"
            }
        },
        {
            "height": 6,
            "width": 10,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "CWAgent", "mem_used_percent", "InstanceId", "${aws_instance.runner.id}" ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "eu-central-1",
                "title": "Memory Utilization",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "height": 6,
            "width": 9,
            "y": 0,
            "x": 14,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.runner.id}" ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "eu-central-1",
                "title": "CPU utilization",
                "period": 60,
                "stat": "Average"
            }
        },
        {
            "height": 6,
            "width": 24,
            "y": 6,
            "x": 0,
            "type": "log",
            "properties": {
                "query": "SOURCE '/aws/ec2/epam-py-runner/' | fields @timestamp, @message\n| filter @message like /Running job/\n| sort @timestamp desc\n| limit 20",
                "region": "eu-central-1",
                "stacked": false,
                "title": "Log group: /aws/ec2/epam-py-runner/",
                "view": "table"
            }
        }
    ]
    }
   EOF 
}