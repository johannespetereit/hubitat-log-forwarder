
const got = require('got');
const tunnel = require('tunnel');
const { CookieJar } = require('tough-cookie');
const cheerio = require('cheerio');

process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = 0;
var session = null;

function extractAppData($aHref) {
  const appId = /\d+$/.exec($aHref.attr('href'))[0]
  const appName = $aHref.text();
  return { id: appId, name: appName };
}

module.exports = {
  async login(baseUrl) {
    console.log("LOGGING IN TO " + baseUrl)
    const cookieJar = new CookieJar();
    const proxy = {
      https: tunnel.httpsOverHttp({
        proxy: {
          host: 'localhost',
          port: 8888
        }
      })
    };
    const getResponse = await got.get(baseUrl + '/login', {
      cookieJar: cookieJar
      // , agent: proxy 
    });
    const postresponse = await got.post(baseUrl + '/login', {
      cookieJar: cookieJar,
      body: "username=" + process.env.HUBITAT_USERNAME + "&password=" + process.env.HUBITAT_PASSWORD + "&submit=Login",
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      // agent: proxy,
      followRedirect: false
    });
    session = cookieJar;
    return cookieJar;
  },

  async getApps(baseUrl) {
    if (session === null) {
      throw "run login() first"
    }
    const appsResponse = await got.get(baseUrl + '/installedapp/list', {
      cookieJar: session
      // agent: proxy 
    });
    const $ = cheerio.load(appsResponse.body);
    $('div.app-row-link [href*="/installedapp/configure/"]').each(function (i, parentApp) {
      var parent = extractAppData($(parentApp));
      console.log(parent.id + "  " + parent.name);
      $(parentApp).closest('td').find('div.app-row-link-child [href*="/installedapp/configure/"]').each(function (i, childApp) {
        var child = extractAppData($(childApp));
        console.log(parent.id + "  " + parent.name + "  " + child.id + "  " + child.name);
      });
    });
  }
}