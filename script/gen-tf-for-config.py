import json
import pdb
from glob import glob
from collections import defaultdict


def is_periodic_rule(parameters):
    return "SourcePeriodic" in parameters["Parameters"]

def is_triggered_rule(parameters):
    return "SourceEvents" in parameters["Parameters"]

def is_managed_rule(parameters):
    return parameters["Parameters"]["CodeKey"] != None

def format_tags(parameters):
    result = '  tags             = {\n'
    if parameters["Tags"]:
        for tag in json.loads(parameters["Tags"]):
            result += '    %s = "%s"\n' % (tag['Key'], tag['Value'])
        return result + '  }'

    else:
        return ''

rule_tmplt = """
resource "aws_config_config_rule" "%s" {
  name             = "%s"
  description      = "%s"
  input_parameters = "%s"
%s

  source {
    owner             = "AWS"
    source_identifier = "%s"
  }

  depends_on = [aws_config_configuration_recorder.config_recorder]
}
"""


for parameters_file in glob('./rules/**/parameters.json'):
    with open(parameters_file) as f:
        parameters = defaultdict(lambda: None, json.load(f))

    # Skip non-managed rules
    if is_managed_rule(parameters):
        continue

    print(
        rule_tmplt %
        (
            parameters["Parameters"]["RuleName"],
            parameters["Parameters"]["RuleName"],
            parameters["Parameters"]["Description"] or '',
            parameters["Parameters"]["InputParameters"].replace('"', '\\"') or '{}',
            format_tags(parameters),
            parameters["Parameters"]["SourceIdentifier"]
        )
    )

