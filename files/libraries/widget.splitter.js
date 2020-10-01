

/*global apex*/
/*!
 Splitter - a jQuery UI based widget for dynamically dividing the available space for two sub regions horizontally or vertically.
 Copyright (c) 2010, 2017, Oracle and/or its affiliates. All rights reserved.
 */
/**
 * @fileOverview
 * The splitter behavior mostly follows the Oracle RCUX guidelines as well as the WAI-ARIA and DHTML Style Guide window
 * splitter design pattern. Differences:
 *  - HOME and END keys not supported and ENTER/SPACE expand and collapse. WAI-ARIA and DHTML Style Guide recommend
 *  HOME and END keys move bar to min or max position and ENTER will "restore splitter to previous position".
 *  RCUX does not define these keyboard behaviors and they do not seem that useful compared to expand/collapse.
 *  - Cycle through splitters uses [Shift+]Ctrl+F6 from WAI-ARIA and not Ctrl+Alt+P from RUCX.
 *  - There is a non collapsing mode that RCUX doesn't describe as well as disabled splitters
 *  - WAI-ARIA recommends setting aria-controls to the two sub region ids but this caused JAWS to read extra
 *  instructions that provided no benefit.
 *
 * Typically the markup for a splitter is a div with two child divs. A separator is inserted between the two
 * divs to split the area of the outer div. The orientation (horizontal or vertical) pertains to the relationship
 * between the two divs and not the orientation of the separator. So horizontal orientation has two divs side by
 * side with a vertical separator between them. Vertical orientation has two divs one on top of the other with a
 * horizontal separator between them. The first child div is always on the left or top.
 *
 * When the window (or splitter container) is resized the extra size is added to (or removed from) the sub region
 * opposite the side the splitter bar is positioned from (See positionedFrom option).
 *
 * To create more complex subdivisions splitter widgets can be nested inside each other. When splitters are nested
 * create the splitters from outer to inner most.
 *
 * Persisting the splitter position either on the client or server is outside the scope of this widget but is easily
 * done by listening to change events.
 *
 * Right to left direction is supported. When the direction is RTL a horizontal splitter will place the first
 * sub region to the right of the bar and the second sub region to the left of the bar.
 *
 * For better accessibility it is recommended to provide a way (perhaps via a menu item) to reset the splitter(s)
 * to their default settings. This is outside the scope of this widget.
 *
 * TODO:
 * - consider independent snap to collapse and min sizes
 * - consider independent control over min/max size
 * - consider control over which side gets extra space on resize
 * - consider saving percentages rather than px values for position - could be done external to widget
 * - future: touch support hopefully comes from jQuery UI
 *
 * Depends:
 *    jquery.ui.core.js
 *    jquery.ui.debug.js
 *    jquery.ui.util.js
 *    jquery.ui.widget.js
 *    jquery.ui.draggable.js
 *    apex/util.js
 */
(function ($, util, debug) {
    "use strict";

    var C_SPLITTER = "a-Splitter",
        SEL_SPLITTER = "." + C_SPLITTER,
        C_SPLITTER_H = "a-Splitter-barH",
        C_SPLITTER_V = "a-Splitter-barV",
        SEL_BAR = "." + C_SPLITTER_H + ",." + C_SPLITTER_V,
        C_SPLITTER_END = "a-Splitter--end",
        C_THUMB = "a-Splitter-thumb",
        SEL_THUMB = "." + C_THUMB,
        C_RTL = "u-RTL",
        C_FOCUSED = "is-focused",
        C_ACTIVE = "is-active",
        C_COLLAPSED = "is-collapsed",
        C_DISABLED = "is-disabled",
        SEL_BUTTON = "button";

    var TITLE = "title";

    $.widget("apex.splitter", {
        version: "5.0",
        widgetEventPrefix: "splitter",
        options: {
            orientation: "horizontal", // or "vertical". Can't change after initialization
            positionedFrom: "begin", // or "end". Controls from which side the position is measured and
            // which side the splitter will collapse toward.
            // Can't change after initialization
            minSize: 60, // min width/height depending on orientation, applies to both child elements
            // avoid very small minSize but it can be 0 if noCollapse is true and 1 if noCollapse is false
            // also ensure that the total width of the splitter will not be less than twice the minSize
            position: 100, // initial position of splitter. Position is always measured from the side that collapses
            noCollapse: false, // if true the splitter cannot be collapsed. Can't change after initialization
            // when true options collapsed, restoreText, collapseText are ignored
            dragCollapse: true, // allow drag operation to collapse
            collapsed: false, // initial collapsed state
            snap: false, // false or number of pixels to snap the separator to
            inc: 10, // number of pixels to move when using the keyboard. A number for snap overrides inc.
            realTime: false, // if true resize children while dragging
            iframeFix: false, // set to true if the splitter moves over an iframe
            restoreText: null, // title text for button handle when collapsed
            collapseText: null, // title text for button handle when expanded
            title: null, // title text for separator
            change: null, // callback when splitter position changes fn(event, { position: <n>, collapsed: <bool> } )
            lazyRender: false, // controls whether the splitter should initialize on being made visible e.g. is behind a tab
            needsResize: false, // controls whether the splitter needs to be resized when being made visible
            visibilityCheckDelay: 300, // number of millseconds to wait after apexreadyend event before checking for visibility for lazy rendering
            immediateVisibilityCheck: false // check immediately if splitter container is visible
        },
        lastPos: null,
        bar$: null,
        before$: null,
        after$: null,
        horiz: true,
        fromEnd: false,
        barSize: 1,

        _create: function () {
            var self = this, o = self.options,
                ctrl$ = self.element,
                el = ctrl$[0];

            if (o.lazyRender) {
                apex.widget.util.onVisibilityChange(el, function (isVisible) {
                    o.isVisible = isVisible;
                    if (isVisible && !o.rendered) {
                        self._initComponent();
                        o.rendered = true;
                    }
                    if (isVisible && o.needsResize) {
                        self._resize();
                        o.needsResize = false;
                    }
                });
                $(window).on('apexreadyend', function () {
                    // we add avariable reference to avoid loss of scope
                    var el = ctrl$[0];
                    // we have to add a slight delay to make sure apex widgets have initialized since (surprisingly) "apexreadyend" is not enough
                    setTimeout(function () {
                        apex.widget.util.visibilityChange(el, true);
                    }, o.visibilityCheckDelay || 1000);
                });
                // check immediately
                if (o.immediateVisibilityCheck) {
                    apex.widget.util.visibilityChange(el, true);
                }
            } else {
                self._initComponent();
            }
        },

        _initComponent: function () {
            var left, top, cursor,
                keyInc, keyDec, pos,
                self = this,
                o = this.options,
                ctrl$ = this.element,
                out = util.htmlBuilder(),
                keys = $.ui.keyCode,
                grid = o.snap ? [o.snap * 1, o.snap * 1] : false,
                minLimit = o.noCollapse ? 0 : 1,
                timerId = null;

            if (ctrl$.children().length !== 2) {
                throw new Error("Splitter must have exactly two children.");
            }
            if (o.orientation !== "horizontal" && o.orientation !== "vertical") {
                throw new Error("Orientation bad value");
            }
            if (o.positionedFrom !== "begin" && o.positionedFrom !== "end") {
                throw new Error("PositionedFrom bad value");
            }

            if (o.minSize < minLimit) {
                o.minSize = minLimit;
                debug.warn("Option minSize adjusted");
            }
            this.horiz = o.orientation === "horizontal";
            this.fromEnd = o.positionedFrom === "end";
            pos = this.horiz ? "left" : "top";
            this.before$ = ctrl$.children().eq(0);
            this.after$ = ctrl$.children().eq(1);
            ctrl$.addClass(C_SPLITTER + " resize");
            if (ctrl$.css("direction") === "rtl") {
                ctrl$.addClass(C_RTL);
                if (this.horiz) {
                    this.before$ = ctrl$.children().eq(1);
                    this.after$ = ctrl$.children().eq(0);
                    this.fromEnd = !this.fromEnd;
                }
            }
            if (ctrl$.parent(SEL_SPLITTER).length > 0 || this.before$.is(SEL_SPLITTER) || this.after$.is(SEL_SPLITTER)) {
                throw new Error("Child of splitter cannot be a splitter");
            }
            if (!this.before$[0].id) {
                this.before$[0].id = (ctrl$[0].id || "splitter") + "_first";
            }
            if (!this.after$[0].id) {
                this.after$[0].id = (ctrl$[0].id || "splitter") + "_second";
            }
            if (o.position < o.minSize) {
                o.position = o.minSize;
            }
            this.lastPos = o.position;
            if (o.snap) {
                o.inc = o.snap;
            }

            // Insert separator bar between the two children
            this._renderBar(out);
            this.bar$ = $(out.toString()).insertAfter(ctrl$.children().eq(0)); // insert in middle independent of direction

            if (this.horiz) {
                this.barSize = this.bar$.width();
            } else {
                this.barSize = this.bar$.height();
            }

            ctrl$.css({
                position: "relative"
            }).children().css({
                position: "absolute"
            });

            if (this.horiz) {
                left = this.bar$.position()[pos];
                top = 0;
                cursor = "e-resize";
                if (this.fromEnd) {
                    keyInc = keys.LEFT;
                    keyDec = keys.RIGHT;
                } else {
                    keyInc = keys.RIGHT;
                    keyDec = keys.LEFT;
                }
            } else {
                left = 0;
                top = this.bar$.position()[pos];
                cursor = "s-resize";
                if (this.fromEnd) {
                    keyInc = keys.UP;
                    keyDec = keys.DOWN;
                } else {
                    keyInc = keys.DOWN;
                    keyDec = keys.UP;
                }
            }

            this.bar$.css({
                left: left,
                top: top
            }).draggable({
                axis: self.horiz ? "x" : "y",
                containment: "parent",
                cancel: SEL_BUTTON,
                cursor: cursor,
                iframeFix: o.iframeFix,
                grid: grid,
                scroll: false,
                drag: function (e, ui) {
                    var p;
                    if (o.realTime) {
                        p = ui.position[pos];
                        if (self.fromEnd) {
                            p = (self.horiz ? ctrl$.width() : ctrl$.height()) - p - self.barSize;
                        }
                        self._setPos(p, false);
                    }
                },
                start: function (e, ui) {
                    self.bar$.addClass(C_ACTIVE);
                },
                stop: function (e, ui) {
                    var p = ui.position[pos];

                    self.bar$.removeClass(C_ACTIVE);
                    if (self.fromEnd) {
                        p = (self.horiz ? ctrl$.width() : ctrl$.height()) - p - self.barSize;
                    }
                    self._setPos(p, false);
                }
            }).click(function () {
                $(this).find(SEL_THUMB).focus();
            }).find(SEL_BUTTON).click(function () {
                self._setPos(self._getPos(), !self._isCollapsed());
            });
            apex.widget.util.TouchProxy.addTouchListeners(this.bar$[0]);
            this.bar$.find(SEL_THUMB).focus(function () {
                $(this).parent().addClass(C_FOCUSED + " " + C_ACTIVE);
            }).blur(function () {
                $(this).parent().removeClass(C_FOCUSED + " " + C_ACTIVE);
            }).keydown(function (e) {
                var max, p1,
                    kc = e.keyCode,
                    p = null,
                    collapsed = false;

                if (kc === keyDec && !o.collapsed) {
                    p = self._getPos();
                    p -= o.inc;
                    if (p < o.minSize && o.noCollapse) {
                        p = o.minSize;
                    }
                    if (p < 0) {
                        p = 0;
                    }
                } else if (kc === keyInc) {
                    p = self._getPos();
                    if (p < 0) {
                        if (!o.noCollapse) {
                            collapsed = true;
                        }
                        p = 0;
                    } else {
                        p += o.inc;
                    }
                    max = self._getMaxPos();
                    if (p > max) {
                        p = max;
                    }
                }
                if (p !== null) {
                    p1 = p;
                    if (self.fromEnd) {
                        p1 = (self.horiz ? ctrl$.width() : ctrl$.height()) - p1 - self.barSize;
                    }
                    self.bar$.css(pos, p1);
                    if (timerId) {
                        clearTimeout(timerId);
                        timerId = null;
                    }
                    timerId = setTimeout(function () {
                        timerId = null;
                        self._setPos(p, collapsed);
                    }, 100);
                    return false;
                }
            });

            this._on(true, this._eventHandlers); // suppress disable check

            if (o.disabled) {
                this._setOption("disabled", o.disabled);
            }
            this.refresh();
        },

        _resize: function (event) {
            var h, w, bounds, offset,
                o = this.options,
                ctrl$ = this.element;

            if (event && event.target !== ctrl$[0]) {
                return;
            }
            h = ctrl$.height();
            w = ctrl$.width();
            if (h === 0 || w === 0) {
                o.needsResize = true;
                return;
                //throw new Error("Splitter needs to be in a component with size");
            }

            offset = ctrl$.offset();
            if (this.horiz) {
                ctrl$.children().each(function () {
                    util.setOuterHeight($(this), h);
                });
                if (this.fromEnd) {
                    bounds = [offset.left + o.minSize, offset.top, offset.left + w - this.barSize, offset.top + h];
                    if (!o.dragCollapse || o.noCollapse) {
                        bounds[2] -= o.minSize;
                    }
                } else {
                    bounds = [offset.left, offset.top, offset.left + w - this.barSize - o.minSize, offset.top + h];
                    if (!o.dragCollapse || o.noCollapse) {
                        bounds[0] += o.minSize + 1;
                    }
                }
            } else {
                ctrl$.children().each(function () {
                    util.setOuterWidth($(this), w);
                });
                if (this.fromEnd) {
                    bounds = [offset.left, offset.top + o.minSize, offset.left + w, offset.top + h - this.barSize];
                    if (!o.dragCollapse || o.noCollapse) {
                        bounds[3] -= o.minSize;
                    }
                } else {
                    bounds = [offset.left, offset.top, offset.left + w, offset.top + h - this.barSize - o.minSize];
                    if (!o.dragCollapse || o.noCollapse) {
                        bounds[1] += o.minSize + 1;
                    }
                }
            }
            this._setPos(o.position, o.collapsed);
            this.bar$.draggable("option", "containment", bounds);
            ctrl$.children(".resize").filter(":visible").trigger("resize");
            if (event) event.stopPropagation();
        },

        _destroy: function () {
            this.element.removeClass(C_SPLITTER + " " + C_DISABLED + " " + C_RTL + " resize")
                .children(SEL_BAR).remove();
            this.element.children().css("position", "");
        },

        refresh: function () {
            if (this.element.is(":visible")) {
                this.element.trigger("resize");
            }
        },

        _setOption: function (key, value) {
            var grid, minLimit, thumb$;

            if (this.options.noCollapse && (key === "collapsed" || key === "restoreText" || key === "collapseText")) {
                debug.warn("Setting " + key + " option on noCollapse splitter has no effect.");
                return;
            }

            if (key === "orientation" || key === "positionedFrom" || key === "noCollapse") {
                // these can't be changed once initialized
                throw new Error("Readonly option: " + key);
            } else if (key === "position") {
                // make sure value is a number
                this._setPos(value * 1, this._isCollapsed());
            } else if (key === "collapsed") {
                // make sure value is boolean
                this._setPos(this._getPos(), !!value);
            } else if (key === "snap") {
                // make sure value is a number if not false
                value = value ? value * 1 : false;
                this.options.snap = value;
                grid = value ? [value, value] : false;
                this.bar$.draggable("option", "grid", grid);
                if (value) {
                    this.options.inc = value;
                }
            } else if (key === "inc") {
                value = value * 1;
                if (this.options.snap) {
                    value = this.options.snap;
                }
                this.options.inc = value;
            } else if (key === "disabled") {
                this.options.disabled = value;
                thumb$ = this.bar$.find(SEL_THUMB);
                if (!this.options.noCollapse) {
                    // disable the button and adjust the tooltip
                    thumb$[0].disabled = value;
                    if (value) {
                        thumb$.attr(TITLE, this.options.title);
                    } else {
                        thumb$.attr(TITLE, this.options.collapsed ? this.options.restoreText : this.options.collapseText);
                    }
                } else {
                    if (value) {
                        thumb$.removeAttr("tabindex");
                    } else {
                        thumb$.attr("tabindex", "0");
                    }
                }
                this.bar$.draggable("option", "disabled", value);
                if (value) {
                    this.element.addClass(C_DISABLED);
                    this.bar$.addClass(C_DISABLED);
                    thumb$.attr("aria-disabled", true);
                } else {
                    thumb$.removeAttr("aria-disabled");
                    this.bar$.removeClass(C_DISABLED);
                    this.element.removeClass(C_DISABLED);
                }
            } else if (key === "minSize") {
                minLimit = this.options.noCollapse ? 0 : 1;
                if (value < minLimit) {
                    value = minLimit;
                    debug.warn("Option minSize adjusted");
                }
                this.options.minSize = value;
            } else {
                $.Widget.prototype._setOption.apply(this, arguments);
            }
            if (key === "title") {
                this.bar$.attr(TITLE, value);
                if (this.options.noCollapse || this.options.disabled) {
                    this.bar$.find(SEL_THUMB).attr(TITLE, value);
                }
            } else if (key === "restoreText" && this.options.collapsed && !this.options.disabled) {
                this.bar$.find(SEL_BUTTON).attr(TITLE, value);
            } else if (key === "collapseText" && !this.options.collapsed && !this.options.disabled) {
                this.bar$.find(SEL_BUTTON).attr(TITLE, value);
            } else if (key === "iframeFix") {
                this.bar$.draggable("option", "iframeFix", value);
            } else if (key === "dragCollapse") {
                this.refresh();
            }
        },

        _eventHandlers: {
            resize: function (event) {
                this._resize(event);
            }
        },


        _renderBar: function (out) {
            var o = this.options,
                barClass = this.horiz ? C_SPLITTER_H : C_SPLITTER_V;

            if (this.fromEnd) {
                barClass += " " + C_SPLITTER_END;
            }
            if (o.noCollapse) {
                o.collapsed = false;
            }
            if (o.collapsed) {
                barClass += " " + C_COLLAPSED;
            }

            out.markup("<div").attr("class", barClass)
                .optionalAttr(TITLE, o.title)
                .markup("><div></div>");
            if (o.noCollapse) {
                out.markup("<span role='separator' class='" + C_THUMB + "' tabindex='0' aria-expanded='true'")
                    .optionalAttr(TITLE, o.title) // duplicate title for the benefit of JAWS
                    // This causes JAWS to give extra instructions that are not useful
                    //  .attr( "aria-controls", this.before$[0].id + " " + this.after$[0].id )
                    .markup("></span>");
            } else {
                out.markup("<button role='separator' class='" + C_THUMB + "' type='button'")
                    .attr("aria-expanded", !o.collapsed)
                    .optionalAttr(TITLE, o.collapsed ? o.restoreText : o.collapseText)
                    // This causes JAWS to give extra instructions that are not useful
                    // .attr( "aria-controls", this.before$[0].id + " " + this.after$[0].id )
                    .markup("></button>");
            }
            out.markup("</div>");
        },

        _getPos: function () {
            var ctrl$ = this.element,
                pos = this.horiz ? "left" : "top",
                p = this.bar$.position()[pos];

            if (this.fromEnd) {
                p = (this.horiz ? ctrl$.width() : ctrl$.height()) - p - this.barSize;
            }
            return p;
        },

        _isCollapsed: function () {
            return this.bar$.hasClass(C_COLLAPSED);
        },

        _getMaxPos: function () {
            var o = this.options,
                ctrl$ = this.element;

            if (this.horiz) {
                return ctrl$.width() - this.barSize - o.minSize;
            } // else
            return ctrl$.height() - this.barSize - o.minSize;
        },

        _setPos: function (position, collapsed) {
            var max, total, child$, childSize, p, thumb$,
                o = this.options,
                ctrl$ = this.element,
                pos = this.horiz ? "left" : "top",
                curCollapsed = this._isCollapsed(),
                curPos = this.lastPos;

            if (o.noCollapse) {
                collapsed = false; // can't be true when noCollapse
            }

            if (curCollapsed && !collapsed) {
                position = this.lastPos;
                if (position < o.minSize) {
                    position = o.minSize;
                }
            }
            if (position < o.minSize) {
                if (o.noCollapse) {
                    position = o.minSize;
                } else {
                    collapsed = true;
                }
            } else {
                max = this._getMaxPos();
                if (position > max) {
                    position = max;
                }
            }
            if (o.noCollapse && position <= 0) {
                position = 0;
            }
            if (position > 0) {
                this.lastPos = position;
            }
            if (collapsed) {
                position = 0;
                o.position = 0;
            }
            total = this.horiz ? ctrl$.width() : ctrl$.height();
            p = position;
            if (this.fromEnd) {
                p = total - position - this.barSize;
            }
            this.bar$.css(pos, p);
            thumb$ = this.bar$.find(SEL_THUMB);

            if (this.fromEnd) {
                child$ = this.after$;
                childSize = total - p - this.barSize;
            } else {
                child$ = this.before$;
                childSize = p;
            }
            if (!collapsed) {
                if (o.noCollapse) {
                    // a noCollapse splitter with minSize 0 can have one or the other children completely closed
                    // but it is not considered "collapsed".
                    // hide if it takes up no space, show otherwise
                    child$.toggle(position !== 0);
                } else {
                    this.bar$.removeClass(C_COLLAPSED);
                    if (!o.noCollapse && !o.disabled) {
                        thumb$.attr("aria-expanded", true).attr(TITLE, o.collapseText);
                    }
                    child$.show();
                }
                if (this.horiz) {
                    util.setOuterWidth(child$, childSize);
                } else {
                    util.setOuterHeight(child$, childSize);
                }
            } else {
                this.bar$.addClass(C_COLLAPSED);
                if (!o.disabled) {
                    thumb$.attr("aria-expanded", false).attr(TITLE, o.restoreText);
                }
                child$.hide();
            }
            if (this.fromEnd) {
                child$ = this.before$;
                childSize = p;
            } else {
                child$ = this.after$;
                childSize = total - p - this.barSize;
            }
            if (this.horiz) {
                util.setOuterWidth(child$, childSize);
            } else {
                util.setOuterHeight(child$, childSize);
            }
            if (o.noCollapse) {
                child$.toggle(childSize !== 0);
            }

            this.after$.css(pos, (p + this.barSize) + "px");
            this.before$.css(pos, 0); // do this in case the dir is rtl
            // if any changes
            if ((!collapsed && position !== curPos) || curCollapsed !== collapsed) {
                o.collapsed = collapsed;
                o.position = position;
                // resize
                ctrl$.children(".resize").filter(":visible").trigger("resize");
                this._trigger("change", {}, {
                    position: o.position,
                    collapsed: o.collapsed,
                    lastPosition: this.lastPos
                });
            }
        }
    });

    var dialogCount = 0,
        menuCount = 0;

    // "Class" method
    // This is typically bound to Ctrl-F6 and if Shift also pressed pass in true for reverse
    $.apex.splitter.nextSplitter = function (reverse) {
        var next$, allBars$, cur,
            inc = reverse ? -1 : 1,
            focused$ = $(document.activeElement);

        if (dialogCount > 0 || menuCount > 0) {
            return;
        }
        allBars$ = $(SEL_SPLITTER + " >." + C_SPLITTER_H + "," + SEL_SPLITTER + " >." + C_SPLITTER_V)
            .filter(":visible")
            .not(".ui-state-disabled")
            .add(focused$);

        cur = allBars$.index(focused$);
        if (cur >= 0) {
            cur += inc;
            if (reverse && focused$.parent().is(SEL_BAR)) {
                cur += inc; // skip over focused
            }
            if (cur >= 0 && cur < allBars$.length) {
                next$ = allBars$.eq(cur);
            }
        }

        if ((next$ && next$.length === 0 && !focused$.parent().is(SEL_BAR)) || focused$.is("html,body")) {
            next$ = $(SEL_SPLITTER + " >." + C_SPLITTER_H + "," + SEL_SPLITTER + " >." + C_SPLITTER_V)
                .filter(":visible")
                .not(".ui-state-disabled")[reverse ? "last" : "first"]();
        }

        if (next$ && next$.length > 0) {
            next$.children(SEL_THUMB).focus();
            return true;
        }
    };

    // on document ready
    $(function () {

        $(document.body).on("menubeforeopen", function ( /*event, ui*/) {
            menuCount += 1;
        }).on("menuafterclose", function ( /*event, ui*/) {
            menuCount -= 1;
        }).on("dialogopen", function ( /*event, ui*/) {
            dialogCount += 1;
        }).on("dialogclose", function ( /*event, ui*/) {
            dialogCount -= 1;
        });

    });

    // when an item is in a splitter that can be collapsed allow the message module to make the item visible
    if (apex.message) {
        apex.message.addVisibilityCheck(function (id) {

            var el$ = $("#" + id);
            el$.parents(".a-Splitter").each(function () {
                // don't know if the item is on the collapsible side or not so only expand if it is not visible
                if (!el$.is(":visible")) {
                    $(this).splitter("option", "collapsed", false);
                }
            });
        });
    }

})(apex.jQuery, apex.util, apex.debug);




