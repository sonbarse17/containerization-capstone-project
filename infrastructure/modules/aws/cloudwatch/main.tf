resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/eks/${var.project_name}-${var.environment}/apps"
  retention_in_days = var.retention_in_days

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 12
        height = 2
        properties = {
          markdown = "# Application Dashboard - ${var.environment}"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_failed_node_count", "ClusterName", "${var.project_name}-${var.environment}-cluster"]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EKS Failed Node Count"
        }
      }
    ]
  })
}
