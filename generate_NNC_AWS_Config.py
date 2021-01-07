from csv2md.table import Table
import json
import glob
from openpyxl import load_workbook
import re
import xml.etree.ElementTree as ET


def headers():
    return [[
        "Control Family",
        "Control ID",
        "Control Name",
        "Control Description",
        "Test Name",
        "Test Description",
        "Test Type",
        "Cloud Resource",
        "Category",
        "Responsibility",
        "Validation Steps",
        "USNORTHCOM Validated"
    ]]


def get_config_rule_data(parameters_path):
    """
    Takes in a path to a control rule configuration's parameters.json file and
    forms the array of data needed to export.

    Positional arguments:
        parameters_path -- Path to parameters.json for a config rule

    Returns: Array of data that may be exported
    """
    file_json = json.loads(open(parameters_path).read())
    parameters = file_json['Parameters'] if 'Tags' in file_json else {}
    tags = json.loads(file_json['Tags']) if 'Tags' in file_json else []
    control_name = parameters['RuleName'] if 'RuleName' in parameters else ''
    test_description = parameters['Description'] if 'Description' in parameters else ''
    test_type = ''
    cloud_resource_category = '' 
    responsibility = ''
    validation_steps = ''
    usnorthcom_validated = ''
    return [
        get_control_family(control_name),
        get_formatted_control_id(control_name),
        get_control_family_expansion(control_name),
        get_control_description(control_name),
        control_name,
        test_description,
        test_type,
        cloud_resource_category,
        responsibility,
        validation_steps,
        usnorthcom_validated
    ]


def get_control_family(control_name):
    """
    Take in a control name (i.e. folder name under 'python/') and parses 
    for the control family abbreviation.

    Example: AC-02_Access_Keys_Rotated => AC

    Positional arguments:
        control_name -- The name of the AWS Config control

    Returns: The expanded control family abbreviation
    """
    match = re.match('^[A-Z]{2}', control_name)
    if match:
        return match.group(0)
    return ''


def get_control_family_expansion(control_name):
    """
    Takes in a control name (i.e. folder name under 'python/') and parses 
    to form the expanded control name.

    Example: AC-02_Access_Keys_Rotated => Access Control

    Positional arguments:
        control_name -- The name of the AWS Config control

    Returns: The expanded control family name
    """
    abbreviation_mapping = {
        'AC': 'Access Control',
        'AU': 'Audit and Accountability',
        'AT': 'Awareness and Training',
        'CM': 'Configuration Management',
        'CP': 'Contingency Planning',
        'IA': 'Identification and Authentication',
        'IR': 'Incident Response',
        'MA': 'Maintenance',
        'MP': 'Media Protection',
        'PS': 'Personnel Security',
        'PE': 'Physical and Environmental Protection',
        'PL': 'Planning',
        'PM': 'Program Management',
        'RA': 'Risk Assessment',
        'CA': 'Security Assessment and Authorization',
        'SC': 'System and Communications Protection',
        'SI': 'System and Information Integrity',
        'SA': 'System and Services Acquisition'
    }
    match = get_control_family(control_name)
    if match in abbreviation_mapping:
        return abbreviation_mapping[match]
    return ''


def get_control_description(control_name):
    """
    Takes in a control name (i.e. folder name under 'python/') and parses 
    to fetch the control description. 

    Positional arguments:
        control_name -- The name of the AWS Config control

    Returns: The control family description
    """
    control_id = get_formatted_control_id(control_name)
    tree = ET.parse('800-53-controls.xml')
    root = tree.getroot()
    description = ''
    element = root.find('.//{http://scap.nist.gov/schema/sp800-53/2.0}number[.="' + control_id + '"]/../{http://scap.nist.gov/schema/sp800-53/2.0}statement')
    if element:
        for e in element.iter():
            is_desc = e.tag == '{http://scap.nist.gov/schema/sp800-53/2.0}description'
            is_number = e.tag == '{http://scap.nist.gov/schema/sp800-53/2.0}number'
            if is_desc or is_number:
                description += e.text + ' '
    return description


def get_formatted_control_id(control_name):
    """
    Takes in a control name (i.e. folder name under 'python/') and parses 
    to form the conventional control ID. 

    Example: AC-02_Access_Keys_Rotated          => AC-2
    Example: AC-06-10_IAM_Root_Access_Key_Check => AC-6(10)

    Positional arguments:
        control_name -- The name of the AWS Config control

    Returns: The properly formatted control ID
    """
    match = re.match('^[A-Z]{2}-[0-9]{2}(-[0-9]{2})?', control_name)
    if match:
        match = match.group(0)
        if (len(match) == 5):
            return f'{match[0:2]}-{str(int(match[3:5]))}'
        return f'{match[0:2]}-{str(int(match[3:5]))} ({str(int(match[6:8]))})'
    return ''


def export(data, md_filename='NNC-AWS-Confg.md', xlsx_filename='NNC-AWS-Confg.xlsx'):
    """
    Exports data to both a markdown document and excel document.

    Positional arguments:
        data -- A 2-dimensional array representing the data to export

    Keyword arguments:
        md_filename -- filename for markdown document (default 'NNC-AWS-Confg.md')
        xlsx_filename -- filename for Excel document (default 'NNC-AWS-Confg.xls')
    """
    # csv2md
    open(md_filename, 'w').write(str(Table(headers() + data).markdown([], [])))

    # openpyxl
    wb = load_workbook(filename='NNC-AWS-Config-TEMPLATE.xlsx')
    sheet = wb.active
    for row in data: 
        sheet.append(row)
    wb.save(filename=xlsx_filename)


def main():
    data = []
    files = glob.glob('python/**/parameters.json')
    files.sort()
    for parameters_path in files:
        data.append(get_config_rule_data(parameters_path))
        # break
    export(data)


if __name__ == '__main__':
    main()
