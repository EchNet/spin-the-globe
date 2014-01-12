var swfName = "globetravel.swf";
var swfId = "_kayak_globe_swf_";
var swfDivId = "swfDiv";
var subtextId = "subtext";
var enabled = false;

var destinations = [
    { name: "Aberdeen, Scotland", latitude: 57.2, longitude: -2.2 },
    { name: "Ankara, Turkey", latitude: 39.8, longitude: 32.8 },
    { name: "Athens, Greece", latitude: 38, longitude: 23.7 },
    { name: "Bangkok, Thailand", latitude: 13.7, longitude: 100.5 },
    { name: "Beijing, China", latitude: 39.9, longitude: 116.4 },
    { name: "Berlin, Germany", latitude: 52.5, longitude: 13.4 },
    { name: "Bogota, Columbia", latitude: 4.5, longitude: -74.3 },
    { name: "Bombay, India", latitude: 19.0, longitude: 72.7 },
    { name: "Buenos Aires, Argentina", latitude: 34.6, longitude: -58.3 },
    { name: "Cape Town, South Africa", latitude: -33.9, longitude: 18.3 },
    { name: "Guatemala City, Guatemala", latitude: 14.6, longitude: -90.5 },
    { name: "Helsinki, Finland", latitude: 60.2, longitude: 25 },
    { name: "Kingston, Jamaica", latitude: 18, longitude: -76.7 },
    { name: "Melbourne, Australia", latitude: -37.6, longitude: 145 },
    { name: "Mexico City, Mexico", latitude: 19.4, longitude: -99.1 },
    { name: "Anchorage, Alaska", latitude: 61.2, longitude: -149.9 },
    { name: "Jacksonville, Florida", latitude: 30.3, longitude: -81.7 }
];

var selectedIndex = 0;

// Shuffle the destination list.
for (var i = 0; i < destinations.length - 1; ++i)
{
    var desig = Math.floor(Math.random()  * destinations.length);
    var temp = destinations[desig];
    destinations[desig] = destinations[i];
    destinations[i] = temp;
}

/**
 * Embed the globe in the page.
 */
function writeSwf()
{
    var swfObj = new SWFObject(swfName, swfId,
                               "100%", "100%",
                               "9", "#ddddff");
    swfObj.addVariable("versionChecked", true);
    swfObj.addVariable("allowScriptAccess", "always");
    swfObj.write(swfDivId);
}

/**
 * Handle events coming from ActionScript.
 */
function jsDispatchEvent(event)
{
    switch (event.type)
    {
    case "ready":
        enabled = true;
        break;
    case "startMotion":
        enabled = false;
        subtext.innerHTML = "(spinning...)";
        break;
    case "stopMotion":
        enabled = true;
        subtext.innerHTML = "Welcome to " + destinations[selectedIndex].name;
        break;
    }
}

/**
 * Choose a destination at random and issue a command to the globe: spin
 * to the specified destination.
 */
function travel()
{
    selectedIndex = (selectedIndex + 1) % destinations.length;

    if (enabled)
    {
        getSwf().asHandleEvent({
            className: "com.kayak.events.CommandEvent",
            command: "travel",
            payload: destinations[selectedIndex]
        });
    }
}

function itsInternetExplorer()
{
    return navigator.appName.indexOf("Microsoft") >= 0;
}

function getSwf()
{
    return itsInternetExplorer() ? window[swfId] : document[swfId];
}

window.onload=writeSwf;
