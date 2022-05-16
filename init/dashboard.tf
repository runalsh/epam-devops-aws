resource "aws_cloudwatch_dashboard" "eks-cluster-application" {
  dashboard_name = "eks-cluster-dash"
  dashboard_body = <<EOF

{
    "widgets": [
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "id": "expr1m0", "label": "${aws_eks_cluster.eks_cluster.name}", "expression": "mm1m0 * 100 / mm0m0", "region": "eu-central-1" } ],
                    [ "ContainerInsights", "node_cpu_limit", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "period": 300, "stat": "Sum", "id": "mm0m0", "visible": false, "region": "eu-central-1" } ],
                    [ "ContainerInsights", "node_cpu_usage_total", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "period": 300, "stat": "Sum", "id": "mm1m0", "visible": false, "region": "eu-central-1" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "CPU Utilization",
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                },
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "timeSeries",
                "stacked": true,
                "period": 300
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "id": "expr1m0", "label": "${aws_eks_cluster.eks_cluster.name}", "expression": "mm1m0 * 100 / mm0m0" } ],
                    [ "ContainerInsights", "node_memory_limit", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "period": 300, "stat": "Sum", "id": "mm0m0", "visible": false } ],
                    [ "ContainerInsights", "node_memory_working_set", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "period": 300, "stat": "Sum", "id": "mm1m0", "visible": false } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "MemoryUtilization",
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                },
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "timeSeries",
                "stacked": true
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ContainerInsights", "node_network_total_bytes", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "period": 300, "stat": "Average" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "Network",
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "timeSeries",
                "stacked": true
            }
        },
        {
            "height": 3,
            "width": 6,
            "y": 0,
            "x": 18,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ContainerInsights", "cluster_node_count", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "period": 300, "stat": "Average" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "EKS:Clusters.NumberOfNodes",
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "singleValue",
                "stacked": false
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 11,
            "x": 12,
            "type": "metric",
            "properties": {
                "region": "eu-central-1",
                "title": "Pods Network",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ { "id": "expr0m0", "label": "prod epamapp-back-prod pod_network_rx_bytes", "expression": "mm0m0 + mm0farm0", "stat": "Average", "yAxis": "left" } ],
                    [ { "id": "expr0m1", "label": "prod epamapp-front-prod pod_network_rx_bytes", "expression": "mm0m1 + mm0farm1", "stat": "Average", "yAxis": "left" } ],
                    [ "ContainerInsights", "pod_network_rx_bytes", "PodName", "epamapp-back-prod", "Namespace", "prod", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "id": "mm0m0", "visible": false, "yAxis": "left" } ],
                    [ "ContainerInsights", "pod_network_rx_bytes", "PodName", "epamapp-front-prod", "Namespace", "prod", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "id": "mm0m1", "visible": false, "yAxis": "left" } ],
                    [ "ContainerInsights", "pod_network_rx_bytes", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", "PodName", "epamapp-back-prod", "Namespace", "prod", "LaunchType", "fargate", { "id": "mm0farm0", "visible": false, "yAxis": "left" } ],
                    [ "ContainerInsights", "pod_network_rx_bytes", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", "PodName", "epamapp-front-prod", "Namespace", "prod", "LaunchType", "fargate", { "id": "mm0farm1", "visible": false, "yAxis": "left" } ],
                    [ { "id": "expr1m0", "label": "prod epamapp-back-prod pod_network_tx_bytes", "expression": "mm1m0 + mm1farm0", "stat": "Average", "yAxis": "right" } ],
                    [ { "id": "expr1m1", "label": "prod epamapp-front-prod pod_network_tx_bytes", "expression": "mm1m1 + mm1farm1", "stat": "Average", "yAxis": "right" } ],
                    [ "ContainerInsights", "pod_network_tx_bytes", "PodName", "epamapp-back-prod", "Namespace", "prod", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "id": "mm1m0", "visible": false, "yAxis": "right" } ],
                    [ "ContainerInsights", "pod_network_tx_bytes", "PodName", "epamapp-front-prod", "Namespace", "prod", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "id": "mm1m1", "visible": false, "yAxis": "right" } ],
                    [ "ContainerInsights", "pod_network_tx_bytes", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", "PodName", "epamapp-back-prod", "Namespace", "prod", "LaunchType", "fargate", { "id": "mm1farm0", "visible": false, "yAxis": "right" } ],
                    [ "ContainerInsights", "pod_network_tx_bytes", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", "PodName", "epamapp-front-prod", "Namespace", "prod", "LaunchType", "fargate", { "id": "mm1farm1", "visible": false, "yAxis": "right" } ]
                ],
                "start": "-P0DT1H0M0S",
                "end": "P0D",
                "liveData": false,
                "period": 60,
                "view": "timeSeries",
                "stacked": false
            }
        },
        {
            "height": 3,
            "width": 6,
            "y": 3,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "eu-central-1",
                "title": "Number of Pods",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "Local",
                "metrics": [
                    [ "ContainerInsights", "node_number_of_running_pods", "InstanceId", "i-041c900efac984628", "NodeName", "ip-10-0-0-164.eu-central-1.compute.internal", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "stat": "Average" } ]
                ],
                "start": "-P0DT1H0M0S",
                "end": "P0D",
                "liveData": false,
                "period": 60,
                "view": "singleValue",
                "stacked": false
            }
        },
        {
            "height": 5,
            "width": 8,
            "y": 6,
            "x": 9,
            "type": "metric",
            "properties": {
                "region": "eu-central-1",
                "title": "Node CPU Utilization",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ "ContainerInsights", "pod_cpu_utilization", "PodName", "epamapp-front-prod", "Namespace", "prod", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_cpu_utilization", "PodName", "epamapp-back-prod", "Namespace", "prod", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_cpu_utilization", "PodName", "epamapp-front-dev", "Namespace", "dev", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_cpu_utilization", "PodName", "epamapp-back-dev", "Namespace", "dev", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "stat": "Average" } ]
                ],
                "start": "-P0DT1H0M0S",
                "end": "P0D",
                "liveData": false,
                "period": 60,
                "view": "timeSeries",
                "stacked": false
            }
        },
        {
            "height": 5,
            "width": 7,
            "y": 6,
            "x": 17,
            "type": "metric",
            "properties": {
                "region": "eu-central-1",
                "title": "Node Memory Utilization",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ "ContainerInsights", "pod_memory_utilization", "PodName", "epamapp-back-prod", "Namespace", "prod", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_memory_utilization", "PodName", "epamapp-front-prod", "Namespace", "prod", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_memory_utilization", "PodName", "epamapp-front-dev", "Namespace", "dev", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_memory_utilization", "PodName", "epamapp-back-dev", "Namespace", "dev", "ClusterName", "${aws_eks_cluster.eks_cluster.name}", { "stat": "Average" } ]
                ],
                "start": "-P0DT1H0M0S",
                "end": "P0D",
                "liveData": false,
                "period": 60,
                "view": "timeSeries",
                "stacked": false
            }
        },
        {
            "height": 3,
            "width": 6,
            "y": 11,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "db", { "period": 300, "stat": "Sum" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "title": "DatabaseConnections: Sum",
                "view": "singleValue",
                "stacked": false
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 11,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "db", { "period": 300, "stat": "Average" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "title": "Database FreeableMemory: Average",
                "view": "timeSeries",
                "stacked": true
            }
        }
    ]
    }
  EOF  
}
