/* global apex,$,$v */

window.FOS = window.FOS || {};

/**
 * @param {object}   config                         Configuration object containing all options
 * @param {string}   config.rediongId               Splitter region ID
 * @param {string}   config.orientation             [horizontal | vertical]
 * @param {string}   config.direction               [begin | end]
 * @param {number}   [config.position]              Splitter starting position in pixels
 * @param {boolean}  [config.collapsed]             Whether the splitter is collapsed on page load
 * @param {string}   [config.positionCode]          Splitter starting position as a proportion [0 | 1/4 | 1/3 | 1/2 | 2/3 | 3/4]
 * @param {function} [config.positionFunction]      A function returning the initial splitter position in pixels
 * @param {number}   config.minSize                 Minimum panel size
 * @param {function} config.heightFunction          A function returning the region height in pixels
 * @param {boolean}  config.persistStatePref        Whether to store the latest position on the server
 * @param {boolean}  config.persistStateLocal       Whether to store the latest position in local storage
 * @param {boolean}  config.lazyRender              Initializes the splitter when the region becomes visible
 * @param {string}   [config.ajaxIdentifier]        AJAX identifier required by persistStatePref
 * @param {boolean}  config.continuousResize        Continuously resize subregions as the splitter is dragged
 * @param {boolean}  config.canCollapse             Whether the splitter can be collapsed
 * @param {boolean}  config.dragCollapse            Whether dragging over the minSize will collapse the splitter
 * @param {boolean}  config.containsIframe          Whether one of the subregions contains an iFrame
 * @param {string}   [config.customSelector]        Custom selector identifying the splitter element under the real region
 * @param {number}   [config.stepSize]              Step size in pixel when dragging
 * @param {number}   [config.keyStepSize]           Step size in pixel when moving via keyboard
 * @param {string}   [config.title]                 Splitter title message
 * @param {string}   [config.titleCollapse]         Splitter button title message when expanded
 * @param {string}   [config.titleRestore]          Splitter button title message when collapsed
 * @param {function} [config.changeFunction]        A function to be invoked every time the splitter moves. function(e, ui){}
 * @param {number}   [config.paddingFirst]          The padding in pixels of the first subregion
 * @param {number}   [config.paddingSecond]         The padding in pixels of the second subregion
 */
(function ($) {
    // constants
    var C_JET_SELECTOR = '[id*="_jet"]',
        C_FOS_SPLITTER_CLASS = 'fos-Splitter',
        C_FOS_SPLITTER_REGION_CLASS = C_FOS_SPLITTER_CLASS + '-region';

    window.FOS.splitter = function (config, initFn) {

        var pluginName = 'FOS - Splitter';
        apex.debug.info(pluginName, config);

        var position, collapsed, splitter$;

        // Allow the developer to perform any last (centralized) changes using Javascript Initialization Code setting
        if (initFn instanceof Function) {
            initFn.call(this, config);
        }

        splitter$ = $('.container', '#' + config.regionId).first();

        function initSplitter() {
            // fire the before render event
            apex.event.trigger('#' + config.regionId, 'fos-splitter-before-render', config);

            splitter$.addClass(C_FOS_SPLITTER_CLASS);
            splitter$.children().addClass(C_FOS_SPLITTER_REGION_CLASS);
            splitter$.attr('id', config.regionId + '_splitter');

            if (config.paddingFirst) {
                splitter$.children().eq(0).css('padding', config.paddingFirst || 'px');
            }
            if (config.paddingSecond) {
                splitter$.children().eq(1).css('padding', config.paddingSecond || 'px');
            }

            // Calculates the initial position of the splitter, and also on resizing events
            function calculatePosition() {

                // calculate the position out of a number of options
                if (config.positionFunction) {
                    position = Math.floor(config.positionFunction());
                } else if (config.positionCode !== undefined) {
                    var code = config.positionCode,
                        size = (config.orientation == 'horizontal' ? splitter$.width() : config.heightFunction());

                    // applying the 0, 1/4, 1/3, 1/2 ... proportions
                    var positionCodeArr = code.split('/');
                    position = positionCodeArr.length > 1 ? Math.floor(size * positionCodeArr[0] / positionCodeArr[1]) : 0;

                    if (position > 0) {
                        position -= 4; // half the splitter width
                    }
                }
                return position;
            }

            // Caculate the splitter position
            config.initialPosition = calculatePosition();

            // override if Persist State as User Preference is enabled
            if (config.persistStatePref && config.position !== undefined && config.collapsed !== undefined) {
                position = config.position;
                collapsed = config.collapsed;
            }

            // override if Persist State in Local Storage is enabled
            var localStorageSupport = apex.storage.hasLocalStorageSupport();
            function getLocalStorageItemName() {
                return 'fos-splitter-' + $v('pFlowId') + '-' + $v('pFlowStepId') + '-' + config.regionId;
            }
            if (config.persistStateLocal && localStorageSupport) {
                var item = localStorage.getItem(getLocalStorageItemName());
                if (item) {
                    try {
                        var value = JSON.parse(item);
                        if (value.position !== undefined) {
                            position = value.position;
                        }
                        if (value.collapsed !== undefined) {
                            collapsed = value.collapsed;
                        }
                    } catch (e) {
                        apex.debug.error(pluginName, 'Could not parse preference from local storage', item);
                    }
                }
            } else if (config.persistStateLocal && !localStorageSupport) {
                apex.debug.warn(pluginName, 'Browser does not have Local Storage Support');
            }

            function setHeight() {
                splitter$.height(config.heightFunction());
            }

            function fixMisc() {
                // takes care of fixing any interactive report headers
                splitter$.find('.js-stickyTableHeader').trigger('forceresize');
                if (config.resizeJetCharts) {
                    resizeJetCharts(50);
                }
            }

            // set the height of our splitter container region
            setHeight();

            // setup responsive resizing
            splitter$.on('resize', function () {
                var newPosition;
                if (!config.persistStatePref && (splitter$.splitter('option', 'position') == config.initialPosition)) {
                    config.initialPosition = newPosition = calculatePosition();
                    splitter$.splitter('option', 'position', newPosition);
                }
                setHeight();
                fixMisc();
            });

            // Initialize the splitter
            splitter$.splitter({
                orientation: config.orientation,
                positionedFrom: config.direction,
                minSize: config.minSize,
                position: position,
                noCollapse: !config.canCollapse,
                dragCollapse: config.dragCollapse,
                collapsed: collapsed || (position == 0 && !config.lazyRender),
                snap: config.stepSize,
                inc: config.keyStepSize,
                realTime: config.continuousResize,
                iframeFix: config.containsIframe,
                restoreText: config.titleRestore,
                collapseText: config.titleCollapse,
                immediateVisibilityCheck: config.lazyRender,
                title: config.title,
                change: function (e, ui) {

                    if (config.persistStatePref) {
                        apex.server.plugin(config.ajaxIdentifier, {
                            x01: ui.lastPosition,
                            x02: ui.collapsed
                        }, {
                            queue: {
                                action: 'lazyWrite',
                                name: 's' + config.regionId
                            }
                        });
                    }

                    if (config.persistStateLocal) {
                        if (localStorageSupport) {
                            localStorage.setItem(getLocalStorageItemName(), JSON.stringify({
                                position: ui.lastPosition,
                                collapsed: ui.collapsed
                            }));
                        } else {
                            apex.debug.warn(pluginName, 'Browser does not have Local Storage Support');
                        }
                    }

                    if (config.changeFunction) {
                        config.changeFunction(e, ui);
                    }

                    fixMisc();

                    // resizes any sub-splitters
                    splitter$.find('.' + C_FOS_SPLITTER_CLASS).trigger('resize');

                    // fire the resize event
                    apex.event.trigger('#' + config.regionId, 'fos-splitter-after-resize', config);
                }
            });

            if (config.resizeJetCharts) {
                // we need to add the height back after the chart is refreshed
                splitter$.on('apexafterrefresh', function () {
                    splitter$.find(C_JET_SELECTOR).height('100%');
                });
                // we only need to change the height on our parents once as they are not touched/changed by APEX
                splitter$.find('.' + C_FOS_SPLITTER_REGION_CLASS).each(function (index, item) {
                    $(item).find(C_JET_SELECTOR).each(function (index, item) {
                        $(item).parent().height('100%').parent().height('100%');
                    });
                });
            }

            // resize any sub-splitters in case of timing issues
            splitter$.find('.' + C_FOS_SPLITTER_CLASS).trigger('resize');

            // fire the after render event
            apex.event.trigger('#' + config.regionId, 'fos-splitter-after-render', config);
        }

        // In order to fit the JET Chart within the region we need to set the height to 100%, as APEX constantly removes it
        function resizeJetCharts(delay) {
            // We need a slight delay to ensure the inbuilt APEX reszing onn the JET widget is completed first
            setTimeout(function () {
                // resize
                splitter$.find(C_JET_SELECTOR).height('100%');
            }, delay || 400);
        }
        /**
         * Main Initialization
         */
        if (config.lazyRender) {
            apex.widget.util.onVisibilityChange(splitter$[0], function (isVisible) {
                config.isVisible = isVisible;
                if (isVisible && !config.rendered) {
                    initSplitter();
                    config.rendered = true;
                } else if (isVisible && config.resizeJetCharts) {
                    // the region is already rendered so we only need a minor delay
                    resizeJetCharts(50);
                }
            });
            $(window).on('apexreadyend', function () {
                // we add avariable reference to avoid loss of scope
                var el = splitter$[0];
                // we have to add a slight delay to make sure apex widgets have initialized since (surprisingly) "apexreadyend" is not enough
                setTimeout(function () {
                    apex.widget.util.visibilityChange(el, true);
                }, config.visibilityCheckDelay || 300);
            });
        } else {
            initSplitter();
        }
    };

    /**
     * External resize handlers
     */
    $(window).on('resize', apex.util.debounce(function () {
        // resize all fos splitters on the page
        $('.' + C_FOS_SPLITTER_CLASS).trigger('resize');
    }, 100));

    // UT specific actions
    $('#t_TreeNav').on('theme42layoutchanged', function () {
        // first wait for the collapse/expand animation to finish
        setTimeout(function () {
            $('.' + C_FOS_SPLITTER_CLASS).trigger('resize');
        }, 250);
    });

    $(window).on('apexreadyend apexwindowresized', function () {
        $('.' + C_FOS_SPLITTER_CLASS).trigger('resize');
    });
})(apex.jQuery);

