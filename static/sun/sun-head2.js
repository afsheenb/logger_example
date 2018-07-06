console.log('updated_head.js file included');

pbjs.bidderTimeout = parseInt( thesun_ad_settings.prebid_timeout ) === 0 || isNaN( parseInt( thesun_ad_settings.prebid_timeout ) ) ? 500 : parseInt( thesun_ad_settings.prebid_timeout ); // If prebid_timeout is 0 then the ad libs will default to 3000, this way we force defaul to 500

// Adomik
(function(i,s,o,g,r,a,m){i['AdomikHeaderBiddingAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)};var pbjs=i.pbjs=(i.pbjs||{});pbjs.que=pbjs.que||[];
    pbjs.que.push(function(){["bidAdjustment","bidTimeout","bidRequested","bidResponse","bidWon"]
        .forEach(function(e){pbjs.onEvent&&pbjs.onEvent(e,function(){i[r]('on',e,arguments);});});});
    a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//127845-hb.adomik.com/ahba.js','ahba');
ahba("set", "uid", "news-127845");

// UNRULY
var unruly = window.unruly || {};
unruly.native = unruly.native || {};

// The parseInt() function parses a string argument and returns an integer of the specified radix.
if ( typeof thesun_unruly_settings != 'undefined' && thesun_unruly_settings.hasOwnProperty( 'site_id' ) && thesun_unruly_settings.site_id != '' ) {
    unruly.native.siteId = parseInt( thesun_unruly_settings.site_id );
} else {
    unruly.native.siteId = 878786;
}

if ( typeof thesun_googletag === 'undefined' ) {
    var thesun_googletag = {
        'hide_ads': true
    }
}

var gtSectionID = ( ( thesun_googletag.sectionID ) ? thesun_googletag.sectionID : 'null' );

function thesun_querySt(ji) {
    hu = window.location.search.substring(1);
    gy = hu.split("&");

    for (i=0;i<gy.length;i++) {
        ft = gy[i].split("=");
        if (ft[0] == ji) {
            return ft[1];
        }
    }
}

var testmode = thesun_querySt("testmode");

if (testmode == "" || undefined) {
    testmode = 'null';
}

// Add section property to bid parameters
if ( typeof thesun_ad_settings.providers === 'undefined' ) {
    thesun_ad_settings.providers = [];
}
if ( thesun_ad_settings.providers.length > 0 ) {
    thesun_ad_settings.providers.forEach( function( elem, idx ) {
        switch( elem.bidder ) {
            case 'rubicon':
                elem.params.section = gtSectionID;
                break;

            case 'appnexus':
                elem.params.inventory = {
                    'section': gtSectionID
                }
                break;

            default:
                break;
        }
    });
}

//set prebid sizes
var w = window;
var d = document;
var e = d.documentElement;
var g = d.getElementsByTagName('body')[0];
var x = w.innerWidth || e.clientWidth || g.clientWidth;
var y = w.innerHeight|| e.clientHeight|| g.clientHeight;
var prebidLeaderboard;
var prebidMPU;

if (x > 969) {
    prebidLeaderboard = [[970,250], [970,90], [728,90]];
    prebidMPU = [[300,600], [300,250]];
}

if (x < 969 && x > 727) {
    prebidLeaderboard = [[970,250], [970,90], [728,90]];
    prebidMPU = [[300,250]];
}

if (x < 727 && x > 467) {
    prebidLeaderboard = [[468,60], [320,50], [320,48], [300,50], [300,48]];
    prebidMPU = [[300,250]];
}

if (x < 467 && x > 301) {
    prebidLeaderboard = [[320,50], [320,48], [300,50], [300,48]];
    prebidMPU = [[300,250]];
}

if (x <= 301) {
    prebidLeaderboard = [[300,50], [300,48]];
    prebidMPU = [[300,250]];
}

(function() {
    window.thesun_targeting = window.thesun_targeting || {};

    //this should be everything past the URL structure but not the page extension (.html, etc).
    thesun_targeting['section'] = thesun_googletag.sectionID;

    //essentially URL path minus the extension
    thesun_targeting['path'] = thesun_googletag.path;

    //populate sec_id with wordpress section ID - for artciles this would be the respective section ID that the article belongs to - not the wordpress post ID.
    thesun_targeting['sec_id'] = thesun_googletag.sec_id;

    //should only contain 2 possible values 'sec' for section/index pages. 'art' for Article pages.
    thesun_targeting['cont_type'] = thesun_googletag.sec;

    //should only populate on article pages. On section pages set the value to 'null'.
    //comma-separated list of keywords popluated from various fields from the article.
    thesun_targeting['kw'] = thesun_googletag.kw;

    //article slug
    thesun_targeting['slug'] = thesun_googletag.article_slug;

    //topics taxonomy
    thesun_targeting['topics'] = thesun_googletag.topics;

    //populate Visitor ID. It's been accepted to leave this unset when Tealium fires late (CA-139)
    if ( window.utag_data ) {
        var tealium_vid = window.utag_data["cp.utag_main_v_id"] || null;
        if ( ! tealium_vid ) {
            var utag_cookie = readCookie( 'utag_main' );
            if ( utag_cookie ) {
                var utag_vid = utag_cookie.match( /v_id:(\w+)/ );
                if ( utag_vid[1] ) {
                    tealium_vid = utag_vid[1];
                }
            }
        }
    }
    thesun_targeting['om_v_id'] = tealium_vid;

    thesun_targeting['om_ses_id'] = 'null';
    //populate Omniture Session ID - talk to Peter Denis or Existing Sun web team on how/where they grab this value from / what the best place to grab it from
    //note the tealium utag object historically has caused latency when used to populate this value

    thesun_targeting['om_s_id'] = 'null';
    //populate Omniture sID - talk to Peter Denis or Existing Sun web team on how/where they grab this value from / what the best place to grab it from
    //note the tealium utag object historically has caused latency when used to populate this value

    thesun_targeting['mpu'] = 'null';
    //set the MPU parameter to 1 if page template/page contains a MPU (300x250) ad-slot. Set to '0' when there's no MPU slot on the page.

    thesun_targeting['eid'] = ( ( getParameterByName( 'eid', decodeURIComponent( readCookie('acs_ngn') ) ) ) ? getParameterByName( 'eid', decodeURIComponent( readCookie('acs_ngn') ) ) : 'null' );
    //if user is logged into the website - pass their subscriber ID - can be read from the acs cookie via the acs_ngn value in the cookie - you will need to extract the subscriber ID from the string which is wrapped in the 'eid' parameter. Set value to 'null' where cookie doesn't exist / user is not logged in.

    thesun_targeting['ppid'] = ( ( getParameterByName( 'ppid', readCookie('acs_ngn') ) ) ? getParameterByName( 'ppid', readCookie('acs_ngn') ) : 'null' );
    //if user is logged into the website - pass their subscriber ID - can be read from the acs cookie via the acs_ngn value in the cookie - you will need to extract the subscriber ID from the string which is wrapped in the 'eid' parameter. Otherwise pass omniture visitor ID.

    thesun_targeting['log'] = ( ( readCookie('acs_ngn') ) ? 1 : 0 );
    //log - logged in or out - set to 0 or 1 - 1 indicating user is logged in - 0 indicating user is logged out.

    thesun_targeting['aid'] = thesun_googletag.aid;
    //aid (article ID) - pass wordpress post ID on article pages. on section pages set this to null.

    thesun_targeting['vid'] = 'null';
    //vid (video IDs) - pass ooyala video embed IDs for any videos contained on the page. Comma seperate if multiple values. If no videos exist set the value to null.

    thesun_targeting['search'] = thesun_googletag.search;
    //search (video IDs) - pass the search term to ad-requests on the search results page. Comma seperate multiple words. Set to null otherwise on all other pages.

    thesun_targeting['ksg'] = localStorage.kxsegs;
    //Krux Segment IDs - read from localStorage.kxsegs. Only pass when values exist in localStorage

    thesun_targeting['kuid'] = localStorage.kxuser;
    //Krux User ID - read from lcoalStorage.kuid. Only pass when values exist in localStorage.

    thesun_targeting['article_type'] = thesun_googletag.article_type;
    //If there are different article templates/type of articles be good to pass these. Set to null on section/index pages.

    thesun_targeting['viewport'] = 'null';
    //Identify viewport colums - 1 col/2 col/3 col - small, medium, large (depending on how many viewports we have/supporting).

    thesun_targeting['testmode'] = testmode;
    //a querystring can be passed to any URL on the site - e.g. ?testmode=rupeshtest. When this is passed - pass the value to this parameter in the ad-request. Where testmode isn't pass set it to 'null'.

    thesun_targeting['refresh'] = 'false';

    thesun_targeting['C'] = ( ( getParameterByName( 'C', readCookie('iam_tgt') ) ) ? getParameterByName( 'C', readCookie('iam_tgt') ) : 'null' );
    //Country Key-value - taken from ACS cookie - only exist for logged in users - do not set or pass this parameter for logged out users.

    thesun_targeting['A'] = ( ( getParameterByName( 'A', readCookie('iam_tgt') ) ) ? getParameterByName( 'A', readCookie('iam_tgt') ) : 'null' );
    //Age Key-value - taken from ACS cookie - only exist for logged in users - do not set or pass this parameter for logged out users.

    thesun_targeting['G'] = ( ( getParameterByName( 'G', readCookie('iam_tgt') ) ) ? getParameterByName( 'G', readCookie('iam_tgt') ) : 'null' );
    //Gender Key-value - taken from ACS cookie - only exist for logged in users - do not set or pass this parameter for logged out users.

    thesun_targeting['P'] = ( ( getParameterByName( 'P', readCookie('iam_tgt') ) ) ? getParameterByName( 'P', readCookie('iam_tgt') ) : 'null' );
    //Post Code Key-value - taken from ACS cookie - only exist for logged in users - do not set or pass this parameter for logged out users.

    window.Adomik = window.Adomik || {};
    Adomik.randomAdGroup = function() {
        var rand = Math.random();
        switch (false) {
            case !(rand < 0.09): return "ad_ex" + (Math.floor(100 * rand));
            case !(rand < 0.10): return "ad_bc";
            default: return "ad_opt";
        }
    };

    function thesun_ad_mvt_segment() {
        return (Math.floor(Math.random() * 10)).toString();
    };

    function setupDFP() {
        var isArticlePage = thesun_targeting.cont_type === 'art';
        var isSection = thesun_targeting.cont_type === 'sec';

        googletag.pubads().disableInitialLoad();

        //set page-level targeting:
        for (key in thesun_targeting) {
            googletag.pubads().setTargeting(key, thesun_targeting[key]);
        }

        googletag.pubads().setTargeting('gs_cat', window.gs_channels);

        googletag.pubads().enableSingleRequest();

        googletag.enableServices();

        googletag.pubads().collapseEmptyDivs();

        //variables defining responsive ad sizes for each ad-slot that has different sizes returned to different viewports
        var leaderMap = googletag.sizeMapping()
            .addSize([1024, 100], [[970, 250], [970, 90], [728, 90]])
            .addSize([727, 100], [728, 90], [468, 60])
            .addSize([467, 100], [[468, 60], [320, 50], [320, 48], [300, 100], [300, 50], [300, 48], [1, 1]])
            .addSize([320, 100], [[320, 50], [320, 48], [300, 50], [1, 1]])
            .addSize([300, 100], [[300, 50], [1, 1]])
            .addSize([0, 0], [])
            .build();

        var doubleMpuMap = googletag.sizeMapping()
            .addSize([1100, 100], [[300, 600], [300, 250], [1, 1]])
            .addSize([300, 100], [[300, 250], [1, 1]])
            .build();

        var mpuMap = googletag.sizeMapping()
            .addSize([1100, 100], [[300, 250], [1, 1]])
            .addSize([300, 100], [[300, 250], [1, 1]])
            .build();

        var articleHeaderMap = googletag.sizeMapping()
            .addSize([0, 0], [[320, 50]])
            .build();

        //start defining each ad slot and their respective parameters
        var networkID = thesun_googletag.networkID;
        var dfpSiteID = thesun_googletag.dfpSiteID;
        var sectionID = thesun_googletag.sectionID;

        //ad Unit Path
        var adUnitPath = networkID + "/" + dfpSiteID + "/" + sectionID;
        googletag.pubads().collapseEmptyDivs();

        //each of these ad positions need to be enabled/disabled via the CMS at a site wide/section-wide/article level.
        //pos values should be configurable.

        googletag.defineSlot(adUnitPath, [[970, 250], [728, 90]], "billboard")
            .addService(googletag.pubads())
            .defineSizeMapping(leaderMap)
            .setTargeting('suntestgroup', thesun_ad_mvt_segment())
            .setTargeting('ad_group', Adomik.randomAdGroup())
            .setTargeting("pos", "leaderboard");

        // Define an ad displayed on the header of an article.
        if (isMobile() && isArticlePage) {
            googletag.defineSlot(adUnitPath, [[320, 50]], "header")
                .addService(googletag.pubads())
                .defineSizeMapping(articleHeaderMap)
                .setTargeting('suntestgroup', thesun_ad_mvt_segment())
                .setTargeting('ad_group', Adomik.randomAdGroup())
                .setTargeting("pos", ("header"));
        }

        // Set "pos" targeting to reflect the display order from top to bottom.
        // mpu, mpu2, mpu3, etc as per current DFP configuration
        var mpuPositionCounter = 1;
        var isSingleColumn = isSidebarHidden();

        if (isSingleColumn && isArticlePage) {
            googletag.defineSlot(adUnitPath, [[300, 250]], 'articlempu')
                .addService(googletag.pubads())
                .defineSizeMapping(mpuMap)
                .setTargeting('suntestgroup', thesun_ad_mvt_segment())
                .setTargeting('ad_group', Adomik.randomAdGroup())
                .setTargeting("pos", ("mpu" + mpuPositionCounter).replace(/1$/, ''));
            mpuPositionCounter++;
        }

        if (isSection || !isSingleColumn) {
            googletag.defineSlot(adUnitPath, [300, 250], 'mpu')
                .addService(googletag.pubads())
                .defineSizeMapping(doubleMpuMap)
                .setTargeting('suntestgroup', thesun_ad_mvt_segment())
                .setTargeting('ad_group', Adomik.randomAdGroup())
                .setTargeting('pos', ('mpu' + mpuPositionCounter).replace(/1$/, ''));
            mpuPositionCounter++;
        }

        // #mpu2 is rendered by Taboola on article pages but rendered by us on section pages
        if (isSection || isSingleColumn) {
            googletag.defineSlot(adUnitPath, [300, 250], 'mpu2')
                .addService(googletag.pubads())
                .defineSizeMapping(isArticlePage ? doubleMpuMap : mpuMap)
                .setTargeting('suntestgroup', thesun_ad_mvt_segment())
                .setTargeting('ad_group', Adomik.randomAdGroup())
                .setTargeting('pos', ('mpu' + mpuPositionCounter).replace(/1$/, ''));
            mpuPositionCounter ++;
        }

        if (isSection || !isSingleColumn) {
            googletag.defineSlot(adUnitPath, [[300,250]], 'mpu3')
                .addService(googletag.pubads())
                .defineSizeMapping(mpuMap)
                .setTargeting('suntestgroup', thesun_ad_mvt_segment())
                .setTargeting('ad_group', Adomik.randomAdGroup())
                .setTargeting('pos', ('mpu' + mpuPositionCounter).replace(/1$/, ''));
            mpuPositionCounter ++;
        }

        googletag.defineSlot(adUnitPath, [1,1], 'pixelTeads')
            .addService(googletag.pubads())
            .setTargeting('pos', 'pixelTeads');

        googletag.defineSlot(adUnitPath,[1, 1], 'pixel')
            .addService(googletag.pubads())
            .setTargeting('pos', 'pixel');

        googletag.defineSlot(adUnitPath,[1, 1], 'pixelSkin')
            .addService(googletag.pubads())
            .setTargeting('pos', 'pixelSkin');

        if (document.getElementById('fillerBlock')) {
            googletag.defineSlot(adUnitPath,[1, 1], 'fillerBlock')
                .addService(googletag.pubads())
                .setTargeting('pos', 'fillerBlock');
        }

        var resizeAds = debounce(function () {
            googletag.pubads().setTargeting("refresh", "true");
            googletag.pubads().refresh();
        }, 250);

        if (!isMobile()) {
            window.addEventListener('resize', resizeAds);
        }

        // Adds the sticky MPU functionality to the MPU ad type.
        function addStickyToAds(event) {
            if (!isMobile() && event.slot.getSlotElementId() === 'mpu') {
                var fixedElement = document.getElementById('mpu'),
                    fixedElementParent = fixedElement.parentElement,
                    offset = 48; // Fixed header.

                // Make sure the sticky ads only applies to article pages.
                if (!document.getElementsByClassName('article-sidebar').length) {
                    return;
                }

                var applyStickyToAds = function () {
                    // Gets the element boundary height, width and position.
                    var fixedElementBound = fixedElement.getBoundingClientRect(),
                        fixedElementParentBound = fixedElementParent.getBoundingClientRect();

                    if (Math.round(fixedElementParentBound.top) <= offset) {
                        if (Math.round(fixedElementParentBound.bottom) > Math.round(fixedElementBound.bottom) || Math.round(fixedElementBound.top) > offset) {
                            removeClass(fixedElement, 'mpu-stick-bottom');
                            addClass(fixedElement, 'mpu-stick-fixed');
                        }
                        else {
                            removeClass(fixedElement, 'mpu-stick-fixed');
                            addClass(fixedElement, 'mpu-stick-bottom');
                        }
                    }
                    else {
                        removeClass(fixedElement, 'mpu-stick-fixed');
                        removeClass(fixedElement, 'mpu-stick-bottom');
                    }
                };

                // Binding event for the window scroll and load.
                window.addEventListener('scroll', applyStickyToAds, false);
                window.addEventListener('load', applyStickyToAds, false);
            }
        }

        var foundDoubleMpu = false;
        googletag.pubads().addEventListener('slotRenderEnded', function (event) {
            addStickyToAds(event);

            if (event.size[0] > 1 && foundDoubleMpu === false && event.slot.getSlotElementId() === 'mpu') {
                var adHeight = Math.max(event.size[1], document.getElementById('mpu').offsetHeight);
                if (adHeight > 500) {
                    document.getElementById('fillerBlock').className += " teasermedium--fillerBlock-remove";
                    document.getElementById('fillerBlock').style.display = "";
                    document.getElementById('mpu').className += " teasermedium--mpu-double";
                    foundDoubleMpu = true;
                } else {
                    document.getElementById('fillerBlock').style.display = "block";
                }
            }
        });
    }

    function parseProviders (code, providers, sizes) {
        providers = JSON.parse(JSON.stringify(providers));
        return providers.reduce(function (list, provider) {
            if (provider.bidder === 'pubmatic') {
                sizes.forEach(function (size) {
                    list.push({
                        bidder: 'pubmatic',
                        params: {
                            publisherId: provider.params.publisherId,
                            adSlot: provider.params.adSlotPrefix + '@' + size.join('x')
                        }
                    });
                });
            } else if (provider.bidder === 'indexExchange') {
                sizes.forEach(function (size) {
                    list.push({
                        bidder: 'indexExchange',
                        params: {
                            id: code,
                            siteID: provider.params.siteID
                        }
                    });
                });
            } else if (provider.bidder === 'criteo') {
                sizes.forEach(function (size) {
                    var zoneId = provider.params['zone_' + size.join('x')];
                    if(zoneId) {
                        list.push({
                            bidder: 'criteo',
                            params: {
                                zoneId: zoneId
                            }
                        });
                    }
                });
            }
            // else if (provider.bidder === 'appnexus-s2s') {
            //     // do nothing
            // }
            else {
                list.push(provider);
            }
            return list;
        }, []);
    }

    function createSlotConfigPrebid(code, providers, sizes) {
        return {
            code: code,
            sizes: sizes,
            bids: parseProviders(code, providers, sizes)
        }
    }

    function createSlotConfigForAmazon(slotID, slotName, sizes) {
        return {
            slotID: slotID,
            slotName: slotName,
            sizes: sizes
        }
    }

    console.log( 'about to declare fetchPrebidBids fn');

    var fetchPrebidBids = new Promise(function(resolve) {

        console.log( 'fetchPrebidBids started execution');

        var isArticlePage = thesun_targeting.cont_type === 'art';

        console.log( 'going to setTimeout around pbjs.que.push');


        // MB 20180418 - added setTimeout here for prebid update

        setTimeout( function () {

            console.log( 'pbjs.que.push has started executing');

            pbjs.que.push(function () {
                // Ad slot config, see prebid.org for more info
                var prebidProviders = thesun_ad_settings.providers.filter(function(p) {
                    return p.bidder !== 'amazon';
                });

                //
                // MB 20180418 - added for prebid update
                // as soon as the prebidProviders array has been created, use this code to push the Lotame & customData into each bid:
                //
                console.log(['going to iterate over prebidProviders:', prebidProviders , 'pbLotameData is : ', pbLotameData]);
                for( var _provider in prebidProviders) {
                    prebidProviders[_provider]['params']['lotame'] = pbLotameData;
                    prebidProviders[_provider]['params']['customData'] = pbCustomData;
                }

                var slots = [
                    createSlotConfigPrebid('billboard', prebidProviders, prebidLeaderboard),
                    createSlotConfigPrebid('mpu', prebidProviders, prebidMPU),
                    createSlotConfigPrebid('mpu2', prebidProviders, isArticlePage ? prebidMPU : [[300, 250]]),
                    createSlotConfigPrebid('mpu3', prebidProviders, isArticlePage ? prebidMPU : [[300, 250]])
                ];

                console.log( 'slots are : ' , slots );

                if (isMobile() && isArticlePage) {
                    slots.push(createSlotConfigPrebid('header', prebidProviders, [[320, 50]]));
                    slots.push(createSlotConfigPrebid('articlempu', prebidProviders, [[300, 250]]));
                }




                const customGranularity = {
                    'buckets' : [
                            {
                                'precision': 2,
                                'min' : 0,
                                'max' : 5,
                                'increment' : 0.02
                            },
                            {
                                'precision': 2,
                                'min' : 8,
                                'max' : 100,
                                'increment' : 0.1
                                 }
                             ]
                         };


						 pbjs.setConfig({  
						     debug: true,  
						     priceGranularity: customGranularity,  //optional
						     enableSendAllBids: true, //optional
						     s2sConfig: {  
						         accountId: '1',  
						         enabled: true,  
						         bidders: ['appnexus','openx'], 
						         timeout: 2000,  
						         adapter: 'prebidServer',  
						         is_debug: 'true',  
						         endpoint: 'https://elb.the-ozone-project.com/openrtb2/auction',  
						         syncEndpoint: 'https://prebid.adnxs.com/pbs/v1/cookie_sync',
						         cookieSet: true,
						         cookiesetUrl: 'https://acdn.adnxs.com/cookieset/cs.js'  
						       },
						       userSync: {
						   iframeEnabled: true
						       }
						 });  





                pbjs.addAdUnits(slots);

                // this is deprecated code - see above
                // pbjs.setPriceGranularity({
                //     'buckets' : [
                //         {
                //             'precision': 2,
                //             'min' : 0,
                //             'max' : 5,
                //             'increment' : 0.02
                //         },
                //         {
                //             'precision': 2,
                //             'min' : 8,
                //             'max' : 100,
                //             'increment' : 0.1
                //         }
                //     ]
                // });

                // pbjs.aliasBidder('appnexus', 'appnexus-s2s');

                pbjs.requestBids({
                    bidsBackHandler: function() {
                        resolve();
                    }
                });
            });

        } , 500 );

    });

    var fetchAmazonBids = new Promise(function(resolve) {
        if (!window.apstag) resolve();

        var isArticlePage = thesun_targeting.cont_type === 'art';

        var networkID = thesun_googletag.networkID;
        var dfpSiteID = thesun_googletag.dfpSiteID;
        var sectionID = thesun_googletag.sectionID;

        //ad Unit Path
        var adUnitPath = networkID + "/" +dfpSiteID+ "/" + sectionID;

        var slots = [
            createSlotConfigForAmazon('billboard', adUnitPath, prebidLeaderboard),
            createSlotConfigForAmazon('mpu', adUnitPath, prebidMPU),
            createSlotConfigForAmazon('mpu2', adUnitPath, isArticlePage ? prebidMPU : [[300, 250]]),
            createSlotConfigForAmazon('mpu3', adUnitPath, isArticlePage ? prebidMPU : [[300, 250]])
        ];

        if (isMobile() && isArticlePage) {
            slots.push(createSlotConfigForAmazon('header', adUnitPath, [[320, 50]]));
            slots.push(createSlotConfigForAmazon('articlempu', adUnitPath, [[300, 250]]));
        }

        apstag.fetchBids({
            slots: slots
        }, function() {
            resolve();
        });
    });

    function applyPreBidTargeting () {
        try {
            if (window.pbjs) {
//                window.pbjs.enableSendAllBids();
                window.pbjs.setTargetingForGPTAsync();
            }
        } catch (exception) {
            console.error('Set Targeting for GTP Async with prebid failed: ', exception);
        }
    }

    function applyAmznTargeting () {
        try {
            if (window.apstag) {
                window.apstag.setDisplayBids();
            }
        } catch (exception) {
            console.error('Set Targeting for GPT Async with amazon failed: ', exception);
        }
    }

    function displayAds () {
        // Sets the winning bid targeting ad slots
        applyPreBidTargeting();
        applyAmznTargeting();
        googletag.pubads().refresh();
        thesun_ad_settings._loaded = true;
    }

    var dfpReady = new Promise(function(resolve) {
        googletag.cmd.push(setupDFP);
        googletag.cmd.push(resolve);
    });



    if (!thesun_googletag.hide_ads) {

        Promise.all([dfpReady, fetchPrebidBids, fetchAmazonBids])
            .then(displayAds);
    }

    /**
     * Check user logged in else return back.
     * Creates a floating widget to preview the page in multiple devices (Mobile, Tablet, Desktop) in the frontend.
     */
    window.onload = function(e){
        if ( document.getElementsByTagName("body")[0].className.match(/(?:^|\s)logged-in(?!\S)/) ) {
            TheSunPreviewFloatingWidget();
        }
    }

    // Brightcove ad targeting
    var iu = thesun_googletag.networkID + '/' + thesun_googletag.dfpSiteID + '/' + thesun_googletag.sectionID;
    var cust_param = '';
    window.thesun_targeting = window.thesun_targeting || {};
    for ( key in thesun_targeting ) {
        cust_param += key + '=' + encodeURIComponent( thesun_targeting[ key ] ) + '&';
    }
    window.iu = iu;
    window.vpaid = "true";  // TODO: take from configuration?
    window.cmsid = "6294"; // TODO: take from configuration?
    window.cust_params = cust_param;

})();

/**
 * Function creates a floating widget in the frontend for various screens i,e Mobile, Tablet, Desktop
 * when editor clicks on the permalink.
 * @return {boolean}
 */
function TheSunPreviewFloatingWidget() {

    var mainDIV, childDiv, elem, fbContainer,
        field      = 'editorialView',
        currentUrl = window.location.href,
        previewDiv = {
            'mobile': { 'name': 'Mobile', 'width': 375, 'height': 667 },
            'tablet': { 'name': 'Tablet', 'width': 768, 'height': screen.height },
            'desktop': { 'name': 'Desktop', 'width': 1200, 'height': screen.height }
        };

    /**
     * Check query string with editorialView=yes exists, else return back
     *
     */
    if ( currentUrl.indexOf( field + '=yes' ) == - 1 ) {
        return false;
    }

    // Remove Query monitor markup.
    elem = document.getElementById( 'qm' );
    elem.parentElement.removeChild( elem );

    // Append classes to Fb like while previewing the Article.
    fbContainer = document.getElementsByClassName( 'social--fb-page-button' );
    if ( fbContainer.length === 1 ) {
        fbContainer[0].className += ' fb_iframe_widget_fluid';
    }

    // Create a Main div.
    mainDIV           = document.createElement( 'div' );
    mainDIV.id        = 'preview-changer';
    mainDIV.className = 'preview-changer';

    for ( prop in previewDiv ) {
        // Create child Div and append to main div.
        childDiv                     = document.createElement( 'button' );
        childDiv.className           = 'preview-change-' + prop;
        childDiv.innerText           = previewDiv[prop]['name'];
        childDiv.dataset.screenwidth = previewDiv[prop]['width'];
        childDiv.dataset.screenheight = previewDiv[prop]['height'];
        childDiv.onclick             = TheSunScreenResizer;
        mainDIV.appendChild( childDiv );
    }

    // Then append the whole child div's onto the body.
    document.getElementsByTagName( 'body' )[0].appendChild( mainDIV );
}

/**
 * Resize the new window based on type of screen i,e Mobile, Tablet, Desktop.
 */
function TheSunScreenResizer() {

    // Mobile Screen.
    if ( this.className === 'preview-change-mobile' ) {
        window.resizeTo( this.dataset.screenwidth, this.dataset.screenheight );
    }

    // Tablet Screen.
    if ( this.className === 'preview-change-tablet' ) {
        window.resizeTo( this.dataset.screenwidth, this.dataset.screenheight );
    }

    // Desktop Screen.
    if ( this.className === 'preview-change-desktop' ) {
        window.resizeTo( this.dataset.screenwidth, this.dataset.screenheight );
    }

    location.reload();
    window.focus();
}
