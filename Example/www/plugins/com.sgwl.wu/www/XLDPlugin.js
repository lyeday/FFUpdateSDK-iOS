cordova.define("com.sgwl.wu.XLDPlugin", function(require, exports, module) {
var exec = require('cordova/exec');
var XLDPlugin =function(){};

XLDPlugin.prototype.setAlias = function (success, error, args) {
    exec(success, error, 'XLDPlugin', 'setAlias', args);
};
XLDPlugin.prototype.clearAlias = function (success, error, args) {
    exec(success, error, 'XLDPlugin', 'clearAlias', args);
};
XLDPlugin.prototype.clearBadgeNumber = function (success, error, args) {
    exec(success, error, 'XLDPlugin', 'clearBadgeNumber', args);
};
XLDPlugin.prototype.videoLivePlayer = function (success, error, args) {
exec(success, error, 'XLDPlugin', 'videoLivePlayer', args);
};
XLDPlugin.prototype.getVideoLiveList = function (success, error, args) {
exec(success, error, 'XLDPlugin', 'getVideoLiveList', args);
};
XLDPlugin.prototype.fourLivePlay = function (success, error, args) {
exec(success, error, 'XLDPlugin', 'fourLivePlay', args);
};
XLDPlugin.prototype.openDocument = function (success, error, args) {
exec(success, error, 'XLDPlugin', 'openDocument', args);
};
XLDPlugin.prototype.getPhoneInfo = function (success, error, args) {
exec(success, error, 'XLDPlugin', 'getPhoneInfo', args);
};
XLDPlugin.prototype.setVHLiveConfig = function (success, error, args) {
exec(success, error, 'XLDPlugin', 'setVHLiveConfig', args);
};
var xldPlugin = new XLDPlugin();
    module.exports = xldPlugin;
});
