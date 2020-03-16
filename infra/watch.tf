resource "aws_iam_role" "misfits_pipeline_start" {
  name = "misfits_pipeline_start"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "misfits_pipeline_start" {
  role = "${aws_iam_role.misfits_pipeline_start.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Resource": [
        "${aws_codepipeline.misfits-pipe.arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_cloudwatch_event_rule" "misfits_pipeline_trigger" {
  name        = "misfits_pipeline_trigger"
  description = "Automatically trigger misfits pipeline"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
    "${data.aws_codecommit_repository.misfit.arn}"
  ],
  "detail": {
    "event": [
      "referenceCreated",
      "referenceUpdated"
    ],
    "referenceType": [
      "branch"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "misfits_pipeline" {
  rule     = "${aws_cloudwatch_event_rule.misfits_pipeline_trigger.name}"
  arn      = "${aws_codepipeline.misfits-pipe.arn}"
  role_arn = "${aws_iam_role.misfits_pipeline_start.arn}"
}