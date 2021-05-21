
from glob import glob
import json
import csv
import pdb

csv_arr = []

with open('NNC-AWS-Config-Rules.csv', 'w', newline='') as csvfile:
    csv_writer = csv.writer(csvfile, quoting=csv.QUOTE_MINIMAL)
    for params_file in glob('rules/**/parameters.json'):
        with open(params_file, 'r') as f:
            params_json = json.loads(f.read())
            params = params_json['Parameters']
            csv_writer.writerow(
                [
                    params['RuleName'],
                    params['SourceIdentifier'] if 'SourceIdentifier' in params else 'N/A',
                    params['Description'] if 'Description' in params else 'N/A'
                ]
            )

pdb.set_trace()


