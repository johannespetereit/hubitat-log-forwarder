const fs = require('fs');
const path_util = require('path');
const debug = require('./debug.js');

module.exports = {
    write: function (data, writer) {
        fs.appendFile(writer.path, JSON.stringify(data), function (err) {
            if (err)
                throw err;
        });
    }
}
