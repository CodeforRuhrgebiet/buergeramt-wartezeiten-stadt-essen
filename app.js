var config = require('./config.json');

var plugins = [];

function exitHandler(options, err) {
    if (options.cleanup) {
        console.log("Closing");
    }
    if (err) console.log(err.stack);
    if (options.exit) process.exit();
}

function checkConfig() {
    if (config) {
        if (config.general) {
            if (config.general.plugins) {
                return 0;
            }
        }
    }
    return 1;
}

function loadPlugins() {
    config.general.plugins.forEach(function (pluginName) {
        try {
            var plugin = require('./plugins/' + pluginName);
            var pluginInstance = new plugin(config[pluginName]);

            var init = pluginInstance.initPlugin();
            if (init == 0) {
                console.log('loading plugin "%s"', pluginName);
                plugins.push(pluginInstance);
            } else {
                console.log('Error at initializing Plugin "%s": %s', pluginName, init);
            }
        } catch (error) {
            console.log('Failed to load Plugin');
        }
    });
}

function getAllData() { //todo rename to better name
    plugins.forEach(function(plugin) {
        console.log(plugin.getCity() + ": " + plugin.getData());
    });
}

if (checkConfig() == 0) {
    console.log('Config check complete');
} else {
    process.abort();
}

loadPlugins();
getAllData();
setInterval(getAllData, 60 * 60 * 24 * 100);


process.stdin.resume();
process.on('exit', exitHandler.bind(null, {cleanup: true}));
process.on('SIGINT', exitHandler.bind(null, {exit: true}));
process.on('uncaughtException', exitHandler.bind(null, {exit: true}));