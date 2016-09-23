var essen = function (config) {
    /**
     * Initialize the Plugin.
     * @returns {*} Return 0 if everything is ok. An String  with the Error Info when not
     */
    this.initPlugin = function () {
        if(config) {
            if(config.enabled == true) {
                return 0;
            } else {
                return "plugin not enabled"
            }
        }
        return "Config mismatch";
    };

    this.getCity = function () { //todo will i let it so?
        return "Essen"
    };

    this.getData = function () { //todo rename to better name
        if (config.enabled == true) {
            return "Hello World!";
        }
    };
};

module.exports = essen;