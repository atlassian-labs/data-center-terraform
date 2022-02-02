const inquirer = require('inquirer');

inquirer
    .prompt([
        {
            type: 'input',
            message: 'Name your terraform environment',
            name: 'envName',
            default: 'my-env-123',
            validate(answer) {
                if (answer.match(/^[a-z][a-z0-9\\-]/g) == null || answer.length > 24) {
                    return `Valid name is up to 24 characters starting with lower case alphabet and followed by alphanumerics. '-' is allowed as well.`;
                }
                return true;
            },
        },
    ])
    .then((answers) => {
        // Use user feedback for... whatever!!
    })
    .catch((error) => {
        if (error.isTtyError) {
            // Prompt couldn't be rendered in the current environment
        } else {
            // Something else went wrong
        }
    });



// const regions = [
//     'us-east-1',
//     'us-east-2',
//     'us-west-1',
//     'us-west-2',
//     'ap-south-1',
//     'ca-central-1',
//     'ap-northeast-1',
//     'ap-southeast-2',
//     'ap-southeast-1',
//     'ap-northeast-2',
//     'eu-central-1',
//     'sa-east-1',
//     'eu-west-1',
//     'eu-west-2',
//     'eu-west-3',
//     'eu-north-1'
// ]