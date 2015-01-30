/* jQuery UI - v1.10.3 - 2014-01-13
 * http://jqueryui.com
 * Includes: jquery.ui.core.js, jquery.ui.widget.js, jquery.ui.position.js, jquery.ui.tooltip.js
 * Copyright 2014 jQuery Foundation and other contributors; Licensed MIT */
(function(b, f) {
    var a = 0,
        e = /^ui-id-\d+$/;
    b.ui = b.ui || {};
    b.extend(b.ui, {
        version: "1.10.3",
        keyCode: {
            BACKSPACE: 8,
            COMMA: 188,
            DELETE: 46,
            DOWN: 40,
            END: 35,
            ENTER: 13,
            ESCAPE: 27,
            HOME: 36,
            LEFT: 37,
            NUMPAD_ADD: 107,
            NUMPAD_DECIMAL: 110,
            NUMPAD_DIVIDE: 111,
            NUMPAD_ENTER: 108,
            NUMPAD_MULTIPLY: 106,
            NUMPAD_SUBTRACT: 109,
            PAGE_DOWN: 34,
            PAGE_UP: 33,
            PERIOD: 190,
            RIGHT: 39,
            SPACE: 32,
            TAB: 9,
            UP: 38
        }
    });
    b.fn.extend({
        focus: (function(g) {
            return function(h, i) {
                return typeof h === "number" ? this.each(function() {
                    var j = this;
                    setTimeout(function() {
                        b(j).focus();
                        if (i) {
                            i.call(j)
                        }
                    }, h)
                }) : g.apply(this, arguments)
            }
        })(b.fn.focus),
        scrollParent: function() {
            var g;
            if ((b.ui.ie && (/(static|relative)/).test(this.css("position"))) || (/absolute/).test(this.css("position"))) {
                g = this.parents().filter(function() {
                    return (/(relative|absolute|fixed)/).test(b.css(this, "position")) && (/(auto|scroll)/).test(b.css(this, "overflow") + b.css(this, "overflow-y") + b.css(this, "overflow-x"))
                }).eq(0)
            } else {
                g = this.parents().filter(function() {
                    return (/(auto|scroll)/).test(b.css(this, "overflow") + b.css(this, "overflow-y") + b.css(this, "overflow-x"))
                }).eq(0)
            }
            return (/fixed/).test(this.css("position")) || !g.length ? b(document) : g
        },
        zIndex: function(j) {
            if (j !== f) {
                return this.css("zIndex", j)
            }
            if (this.length) {
                var h = b(this[0]),
                    g, i;
                while (h.length && h[0] !== document) {
                    g = h.css("position");
                    if (g === "absolute" || g === "relative" || g === "fixed") {
                        i = parseInt(h.css("zIndex"), 10);
                        if (!isNaN(i) && i !== 0) {
                            return i
                        }
                    }
                    h = h.parent()
                }
            }
            return 0
        },
        uniqueId: function() {
            return this.each(function() {
                if (!this.id) {
                    this.id = "ui-id-" + (++a)
                }
            })
        },
        removeUniqueId: function() {
            return this.each(function() {
                if (e.test(this.id)) {
                    b(this).removeAttr("id")
                }
            })
        }
    });

    function d(i, g) {
        var k, j, h, l = i.nodeName.toLowerCase();
        if ("area" === l) {
            k = i.parentNode;
            j = k.name;
            if (!i.href || !j || k.nodeName.toLowerCase() !== "map") {
                return false
            }
            h = b("img[usemap=#" + j + "]")[0];
            return !!h && c(h)
        }
        return (/input|select|textarea|button|object/.test(l) ? !i.disabled : "a" === l ? i.href || g : g) && c(i)
    }

    function c(g) {
        return b.expr.filters.visible(g) && !b(g).parents().addBack().filter(function() {
            return b.css(this, "visibility") === "hidden"
        }).length
    }
    b.extend(b.expr[":"], {
        data: b.expr.createPseudo ? b.expr.createPseudo(function(g) {
            return function(h) {
                return !!b.data(h, g)
            }
        }) : function(j, h, g) {
            return !!b.data(j, g[3])
        },
        focusable: function(g) {
            return d(g, !isNaN(b.attr(g, "tabindex")))
        },
        tabbable: function(i) {
            var g = b.attr(i, "tabindex"),
                h = isNaN(g);
            return (h || g >= 0) && d(i, !h)
        }
    });
    if (!b("<a>").outerWidth(1).jquery) {
        b.each(["Width", "Height"], function(j, g) {
            var h = g === "Width" ? ["Left", "Right"] : ["Top", "Bottom"],
                k = g.toLowerCase(),
                m = {
                    innerWidth: b.fn.innerWidth,
                    innerHeight: b.fn.innerHeight,
                    outerWidth: b.fn.outerWidth,
                    outerHeight: b.fn.outerHeight
                };

            function l(o, n, i, p) {
                b.each(h, function() {
                    n -= parseFloat(b.css(o, "padding" + this)) || 0;
                    if (i) {
                        n -= parseFloat(b.css(o, "border" + this + "Width")) || 0
                    }
                    if (p) {
                        n -= parseFloat(b.css(o, "margin" + this)) || 0
                    }
                });
                return n
            }
            b.fn["inner" + g] = function(i) {
                if (i === f) {
                    return m["inner" + g].call(this)
                }
                return this.each(function() {
                    b(this).css(k, l(this, i) + "px")
                })
            };
            b.fn["outer" + g] = function(i, n) {
                if (typeof i !== "number") {
                    return m["outer" + g].call(this, i)
                }
                return this.each(function() {
                    b(this).css(k, l(this, i, true, n) + "px")
                })
            }
        })
    }
    if (!b.fn.addBack) {
        b.fn.addBack = function(g) {
            return this.add(g == null ? this.prevObject : this.prevObject.filter(g))
        }
    }
    if (b("<a>").data("a-b", "a").removeData("a-b").data("a-b")) {
        b.fn.removeData = (function(g) {
            return function(h) {
                if (arguments.length) {
                    return g.call(this, b.camelCase(h))
                } else {
                    return g.call(this)
                }
            }
        })(b.fn.removeData)
    }
    b.ui.ie = !!/msie [\w.]+/.exec(navigator.userAgent.toLowerCase());
    b.support.selectstart = "onselectstart" in document.createElement("div");
    b.fn.extend({
        disableSelection: function() {
            return this.bind((b.support.selectstart ? "selectstart" : "mousedown") + ".ui-disableSelection", function(g) {
                g.preventDefault()
            })
        },
        enableSelection: function() {
            return this.unbind(".ui-disableSelection")
        }
    });
    b.extend(b.ui, {
        plugin: {
            add: function(h, j, l) {
                var g, k = b.ui[h].prototype;
                for (g in l) {
                    k.plugins[g] = k.plugins[g] || [];
                    k.plugins[g].push([j, l[g]])
                }
            },
            call: function(g, j, h) {
                var k, l = g.plugins[j];
                if (!l || !g.element[0].parentNode || g.element[0].parentNode.nodeType === 11) {
                    return
                }
                for (k = 0; k < l.length; k++) {
                    if (g.options[l[k][0]]) {
                        l[k][1].apply(g.element, h)
                    }
                }
            }
        },
        hasScroll: function(j, h) {
            if (b(j).css("overflow") === "hidden") {
                return false
            }
            var g = (h && h === "left") ? "scrollLeft" : "scrollTop",
                i = false;
            if (j[g] > 0) {
                return true
            }
            j[g] = 1;
            i = (j[g] > 0);
            j[g] = 0;
            return i
        }
    })
})(jQuery);
(function(b, e) {
    var a = 0,
        d = Array.prototype.slice,
        c = b.cleanData;
    b.cleanData = function(f) {
        for (var g = 0, h;
            (h = f[g]) != null; g++) {
            try {
                b(h).triggerHandler("remove")
            } catch (j) {}
        }
        c(f)
    };
    b.widget = function(f, g, n) {
        var k, l, i, m, h = {},
            j = f.split(".")[0];
        f = f.split(".")[1];
        k = j + "-" + f;
        if (!n) {
            n = g;
            g = b.Widget
        }
        b.expr[":"][k.toLowerCase()] = function(o) {
            return !!b.data(o, k)
        };
        b[j] = b[j] || {};
        l = b[j][f];
        i = b[j][f] = function(o, p) {
            if (!this._createWidget) {
                return new i(o, p)
            }
            if (arguments.length) {
                this._createWidget(o, p)
            }
        };
        b.extend(i, l, {
            version: n.version,
            _proto: b.extend({}, n),
            _childConstructors: []
        });
        m = new g();
        m.options = b.widget.extend({}, m.options);
        b.each(n, function(p, o) {
            if (!b.isFunction(o)) {
                h[p] = o;
                return
            }
            h[p] = (function() {
                var q = function() {
                        return g.prototype[p].apply(this, arguments)
                    },
                    r = function(s) {
                        return g.prototype[p].apply(this, s)
                    };
                return function() {
                    var u = this._super,
                        s = this._superApply,
                        t;
                    this._super = q;
                    this._superApply = r;
                    t = o.apply(this, arguments);
                    this._super = u;
                    this._superApply = s;
                    return t
                }
            })()
        });
        i.prototype = b.widget.extend(m, {
            widgetEventPrefix: l ? m.widgetEventPrefix : f
        }, h, {
            constructor: i,
            namespace: j,
            widgetName: f,
            widgetFullName: k
        });
        if (l) {
            b.each(l._childConstructors, function(p, q) {
                var o = q.prototype;
                b.widget(o.namespace + "." + o.widgetName, i, q._proto)
            });
            delete l._childConstructors
        } else {
            g._childConstructors.push(i)
        }
        b.widget.bridge(f, i)
    };
    b.widget.extend = function(k) {
        var g = d.call(arguments, 1),
            j = 0,
            f = g.length,
            h, i;
        for (; j < f; j++) {
            for (h in g[j]) {
                i = g[j][h];
                if (g[j].hasOwnProperty(h) && i !== e) {
                    if (b.isPlainObject(i)) {
                        k[h] = b.isPlainObject(k[h]) ? b.widget.extend({}, k[h], i) : b.widget.extend({}, i)
                    } else {
                        k[h] = i
                    }
                }
            }
        }
        return k
    };
    b.widget.bridge = function(g, f) {
        var h = f.prototype.widgetFullName || g;
        b.fn[g] = function(k) {
            var i = typeof k === "string",
                j = d.call(arguments, 1),
                l = this;
            k = !i && j.length ? b.widget.extend.apply(null, [k].concat(j)) : k;
            if (i) {
                this.each(function() {
                    var n, m = b.data(this, h);
                    if (!m) {
                        return b.error("cannot call methods on " + g + " prior to initialization; attempted to call method '" + k + "'")
                    }
                    if (!b.isFunction(m[k]) || k.charAt(0) === "_") {
                        return b.error("no such method '" + k + "' for " + g + " widget instance")
                    }
                    n = m[k].apply(m, j);
                    if (n !== m && n !== e) {
                        l = n && n.jquery ? l.pushStack(n.get()) : n;
                        return false
                    }
                })
            } else {
                this.each(function() {
                    var m = b.data(this, h);
                    if (m) {
                        m.option(k || {})._init()
                    } else {
                        b.data(this, h, new f(k, this))
                    }
                })
            }
            return l
        }
    };
    b.Widget = function() {};
    b.Widget._childConstructors = [];
    b.Widget.prototype = {
        widgetName: "widget",
        widgetEventPrefix: "",
        defaultElement: "<div>",
        options: {
            disabled: false,
            create: null
        },
        _createWidget: function(f, g) {
            g = b(g || this.defaultElement || this)[0];
            this.element = b(g);
            this.uuid = a++;
            this.eventNamespace = "." + this.widgetName + this.uuid;
            this.options = b.widget.extend({}, this.options, this._getCreateOptions(), f);
            this.bindings = b();
            this.hoverable = b();
            this.focusable = b();
            if (g !== this) {
                b.data(g, this.widgetFullName, this);
                this._on(true, this.element, {
                    remove: function(h) {
                        if (h.target === g) {
                            this.destroy()
                        }
                    }
                });
                this.document = b(g.style ? g.ownerDocument : g.document || g);
                this.window = b(this.document[0].defaultView || this.document[0].parentWindow)
            }
            this._create();
            this._trigger("create", null, this._getCreateEventData());
            this._init()
        },
        _getCreateOptions: b.noop,
        _getCreateEventData: b.noop,
        _create: b.noop,
        _init: b.noop,
        destroy: function() {
            this._destroy();
            this.element.unbind(this.eventNamespace).removeData(this.widgetName).removeData(this.widgetFullName).removeData(b.camelCase(this.widgetFullName));
            this.widget().unbind(this.eventNamespace).removeAttr("aria-disabled").removeClass(this.widgetFullName + "-disabled ui-state-disabled");
            this.bindings.unbind(this.eventNamespace);
            this.hoverable.removeClass("ui-state-hover");
            this.focusable.removeClass("ui-state-focus")
        },
        _destroy: b.noop,
        widget: function() {
            return this.element
        },
        option: function(j, k) {
            var f = j,
                l, h, g;
            if (arguments.length === 0) {
                return b.widget.extend({}, this.options)
            }
            if (typeof j === "string") {
                f = {};
                l = j.split(".");
                j = l.shift();
                if (l.length) {
                    h = f[j] = b.widget.extend({}, this.options[j]);
                    for (g = 0; g < l.length - 1; g++) {
                        h[l[g]] = h[l[g]] || {};
                        h = h[l[g]]
                    }
                    j = l.pop();
                    if (k === e) {
                        return h[j] === e ? null : h[j]
                    }
                    h[j] = k
                } else {
                    if (k === e) {
                        return this.options[j] === e ? null : this.options[j]
                    }
                    f[j] = k
                }
            }
            this._setOptions(f);
            return this
        },
        _setOptions: function(f) {
            var g;
            for (g in f) {
                this._setOption(g, f[g])
            }
            return this
        },
        _setOption: function(f, g) {
            this.options[f] = g;
            if (f === "disabled") {
                this.widget().toggleClass(this.widgetFullName + "-disabled ui-state-disabled", !!g).attr("aria-disabled", g);
                this.hoverable.removeClass("ui-state-hover");
                this.focusable.removeClass("ui-state-focus")
            }
            return this
        },
        enable: function() {
            return this._setOption("disabled", false)
        },
        disable: function() {
            return this._setOption("disabled", true)
        },
        _on: function(i, h, g) {
            var j, f = this;
            if (typeof i !== "boolean") {
                g = h;
                h = i;
                i = false
            }
            if (!g) {
                g = h;
                h = this.element;
                j = this.widget()
            } else {
                h = j = b(h);
                this.bindings = this.bindings.add(h)
            }
            b.each(g, function(p, o) {
                function m() {
                    if (!i && (f.options.disabled === true || b(this).hasClass("ui-state-disabled"))) {
                        return
                    }
                    return (typeof o === "string" ? f[o] : o).apply(f, arguments)
                }
                if (typeof o !== "string") {
                    m.guid = o.guid = o.guid || m.guid || b.guid++
                }
                var n = p.match(/^(\w+)\s*(.*)$/),
                    l = n[1] + f.eventNamespace,
                    k = n[2];
                if (k) {
                    j.delegate(k, l, m)
                } else {
                    h.bind(l, m)
                }
            })
        },
        _off: function(g, f) {
            f = (f || "").split(" ").join(this.eventNamespace + " ") + this.eventNamespace;
            g.unbind(f).undelegate(f)
        },
        _delay: function(i, h) {
            function g() {
                return (typeof i === "string" ? f[i] : i).apply(f, arguments)
            }
            var f = this;
            return setTimeout(g, h || 0)
        },
        _hoverable: function(f) {
            this.hoverable = this.hoverable.add(f);
            this._on(f, {
                mouseenter: function(g) {
                    b(g.currentTarget).addClass("ui-state-hover")
                },
                mouseleave: function(g) {
                    b(g.currentTarget).removeClass("ui-state-hover")
                }
            })
        },
        _focusable: function(f) {
            this.focusable = this.focusable.add(f);
            this._on(f, {
                focusin: function(g) {
                    b(g.currentTarget).addClass("ui-state-focus")
                },
                focusout: function(g) {
                    b(g.currentTarget).removeClass("ui-state-focus")
                }
            })
        },
        _trigger: function(f, g, h) {
            var k, j, i = this.options[f];
            h = h || {};
            g = b.Event(g);
            g.type = (f === this.widgetEventPrefix ? f : this.widgetEventPrefix + f).toLowerCase();
            g.target = this.element[0];
            j = g.originalEvent;
            if (j) {
                for (k in j) {
                    if (!(k in g)) {
                        g[k] = j[k]
                    }
                }
            }
            this.element.trigger(g, h);
            return !(b.isFunction(i) && i.apply(this.element[0], [g].concat(h)) === false || g.isDefaultPrevented())
        }
    };
    b.each({
        show: "fadeIn",
        hide: "fadeOut"
    }, function(g, f) {
        b.Widget.prototype["_" + g] = function(j, i, l) {
            if (typeof i === "string") {
                i = {
                    effect: i
                }
            }
            var k, h = !i ? g : i === true || typeof i === "number" ? f : i.effect || f;
            i = i || {};
            if (typeof i === "number") {
                i = {
                    duration: i
                }
            }
            k = !b.isEmptyObject(i);
            i.complete = l;
            if (i.delay) {
                j.delay(i.delay)
            }
            if (k && b.effects && b.effects.effect[h]) {
                j[g](i)
            } else {
                if (h !== g && j[h]) {
                    j[h](i.duration, i.easing, l)
                } else {
                    j.queue(function(m) {
                        b(this)[g]();
                        if (l) {
                            l.call(j[0])
                        }
                        m()
                    })
                }
            }
        }
    })
})(jQuery);
(function(e, c) {
    e.ui = e.ui || {};
    var j, k = Math.max,
        o = Math.abs,
        m = Math.round,
        d = /left|center|right/,
        h = /top|center|bottom/,
        a = /[\+\-]\d+(\.[\d]+)?%?/,
        l = /^\w+/,
        b = /%$/,
        g = e.fn.position;

    function n(r, q, p) {
        return [parseFloat(r[0]) * (b.test(r[0]) ? q / 100 : 1), parseFloat(r[1]) * (b.test(r[1]) ? p / 100 : 1)]
    }

    function i(p, q) {
        return parseInt(e.css(p, q), 10) || 0
    }

    function f(q) {
        var p = q[0];
        if (p.nodeType === 9) {
            return {
                width: q.width(),
                height: q.height(),
                offset: {
                    top: 0,
                    left: 0
                }
            }
        }
        if (e.isWindow(p)) {
            return {
                width: q.width(),
                height: q.height(),
                offset: {
                    top: q.scrollTop(),
                    left: q.scrollLeft()
                }
            }
        }
        if (p.preventDefault) {
            return {
                width: 0,
                height: 0,
                offset: {
                    top: p.pageY,
                    left: p.pageX
                }
            }
        }
        return {
            width: q.outerWidth(),
            height: q.outerHeight(),
            offset: q.offset()
        }
    }
    e.position = {
        scrollbarWidth: function() {
            if (j !== c) {
                return j
            }
            var q, p, s = e("<div style='display:block;width:50px;height:50px;overflow:hidden;'><div style='height:100px;width:auto;'></div></div>"),
                r = s.children()[0];
            e("body").append(s);
            q = r.offsetWidth;
            s.css("overflow", "scroll");
            p = r.offsetWidth;
            if (q === p) {
                p = s[0].clientWidth
            }
            s.remove();
            return (j = q - p)
        },
        getScrollInfo: function(t) {
            var s = t.isWindow ? "" : t.element.css("overflow-x"),
                r = t.isWindow ? "" : t.element.css("overflow-y"),
                q = s === "scroll" || (s === "auto" && t.width < t.element[0].scrollWidth),
                p = r === "scroll" || (r === "auto" && t.height < t.element[0].scrollHeight);
            return {
                width: p ? e.position.scrollbarWidth() : 0,
                height: q ? e.position.scrollbarWidth() : 0
            }
        },
        getWithinInfo: function(q) {
            var r = e(q || window),
                p = e.isWindow(r[0]);
            return {
                element: r,
                isWindow: p,
                offset: r.offset() || {
                    left: 0,
                    top: 0
                },
                scrollLeft: r.scrollLeft(),
                scrollTop: r.scrollTop(),
                width: p ? r.width() : r.outerWidth(),
                height: p ? r.height() : r.outerHeight()
            }
        }
    };
    e.fn.position = function(z) {
        if (!z || !z.of) {
            return g.apply(this, arguments)
        }
        z = e.extend({}, z);
        var A, w, u, y, t, p, v = e(z.of),
            s = e.position.getWithinInfo(z.within),
            q = e.position.getScrollInfo(s),
            x = (z.collision || "flip").split(" "),
            r = {};
        p = f(v);
        if (v[0].preventDefault) {
            z.at = "left top"
        }
        w = p.width;
        u = p.height;
        y = p.offset;
        t = e.extend({}, y);
        e.each(["my", "at"], function() {
            var D = (z[this] || "").split(" "),
                C, B;
            if (D.length === 1) {
                D = d.test(D[0]) ? D.concat(["center"]) : h.test(D[0]) ? ["center"].concat(D) : ["center", "center"]
            }
            D[0] = d.test(D[0]) ? D[0] : "center";
            D[1] = h.test(D[1]) ? D[1] : "center";
            C = a.exec(D[0]);
            B = a.exec(D[1]);
            r[this] = [C ? C[0] : 0, B ? B[0] : 0];
            z[this] = [l.exec(D[0])[0], l.exec(D[1])[0]]
        });
        if (x.length === 1) {
            x[1] = x[0]
        }
        if (z.at[0] === "right") {
            t.left += w
        } else {
            if (z.at[0] === "center") {
                t.left += w / 2
            }
        }
        if (z.at[1] === "bottom") {
            t.top += u
        } else {
            if (z.at[1] === "center") {
                t.top += u / 2
            }
        }
        A = n(r.at, w, u);
        t.left += A[0];
        t.top += A[1];
        return this.each(function() {
            var C, L, E = e(this),
                G = E.outerWidth(),
                D = E.outerHeight(),
                F = i(this, "marginLeft"),
                B = i(this, "marginTop"),
                K = G + F + i(this, "marginRight") + q.width,
                J = D + B + i(this, "marginBottom") + q.height,
                H = e.extend({}, t),
                I = n(r.my, E.outerWidth(), E.outerHeight());
            if (z.my[0] === "right") {
                H.left -= G
            } else {
                if (z.my[0] === "center") {
                    H.left -= G / 2
                }
            }
            if (z.my[1] === "bottom") {
                H.top -= D
            } else {
                if (z.my[1] === "center") {
                    H.top -= D / 2
                }
            }
            H.left += I[0];
            H.top += I[1];
            if (!e.support.offsetFractions) {
                H.left = m(H.left);
                H.top = m(H.top)
            }
            C = {
                marginLeft: F,
                marginTop: B
            };
            e.each(["left", "top"], function(N, M) {
                if (e.ui.position[x[N]]) {
                    e.ui.position[x[N]][M](H, {
                        targetWidth: w,
                        targetHeight: u,
                        elemWidth: G,
                        elemHeight: D,
                        collisionPosition: C,
                        collisionWidth: K,
                        collisionHeight: J,
                        offset: [A[0] + I[0], A[1] + I[1]],
                        my: z.my,
                        at: z.at,
                        within: s,
                        elem: E
                    })
                }
            });
            if (z.using) {
                L = function(P) {
                    var R = y.left - H.left,
                        O = R + w - G,
                        Q = y.top - H.top,
                        N = Q + u - D,
                        M = {
                            target: {
                                element: v,
                                left: y.left,
                                top: y.top,
                                width: w,
                                height: u
                            },
                            element: {
                                element: E,
                                left: H.left,
                                top: H.top,
                                width: G,
                                height: D
                            },
                            horizontal: O < 0 ? "left" : R > 0 ? "right" : "center",
                            vertical: N < 0 ? "top" : Q > 0 ? "bottom" : "middle"
                        };
                    if (w < G && o(R + O) < w) {
                        M.horizontal = "center"
                    }
                    if (u < D && o(Q + N) < u) {
                        M.vertical = "middle"
                    }
                    if (k(o(R), o(O)) > k(o(Q), o(N))) {
                        M.important = "horizontal"
                    } else {
                        M.important = "vertical"
                    }
                    z.using.call(this, P, M)
                }
            }
            E.offset(e.extend(H, {
                using: L
            }))
        })
    };
    e.ui.position = {
        fit: {
            left: function(t, s) {
                var r = s.within,
                    v = r.isWindow ? r.scrollLeft : r.offset.left,
                    x = r.width,
                    u = t.left - s.collisionPosition.marginLeft,
                    w = v - u,
                    q = u + s.collisionWidth - x - v,
                    p;
                if (s.collisionWidth > x) {
                    if (w > 0 && q <= 0) {
                        p = t.left + w + s.collisionWidth - x - v;
                        t.left += w - p
                    } else {
                        if (q > 0 && w <= 0) {
                            t.left = v
                        } else {
                            if (w > q) {
                                t.left = v + x - s.collisionWidth
                            } else {
                                t.left = v
                            }
                        }
                    }
                } else {
                    if (w > 0) {
                        t.left += w
                    } else {
                        if (q > 0) {
                            t.left -= q
                        } else {
                            t.left = k(t.left - u, t.left)
                        }
                    }
                }
            },
            top: function(s, r) {
                var q = r.within,
                    w = q.isWindow ? q.scrollTop : q.offset.top,
                    x = r.within.height,
                    u = s.top - r.collisionPosition.marginTop,
                    v = w - u,
                    t = u + r.collisionHeight - x - w,
                    p;
                if (r.collisionHeight > x) {
                    if (v > 0 && t <= 0) {
                        p = s.top + v + r.collisionHeight - x - w;
                        s.top += v - p
                    } else {
                        if (t > 0 && v <= 0) {
                            s.top = w
                        } else {
                            if (v > t) {
                                s.top = w + x - r.collisionHeight
                            } else {
                                s.top = w
                            }
                        }
                    }
                } else {
                    if (v > 0) {
                        s.top += v
                    } else {
                        if (t > 0) {
                            s.top -= t
                        } else {
                            s.top = k(s.top - u, s.top)
                        }
                    }
                }
            }
        },
        flip: {
            left: function(v, u) {
                var t = u.within,
                    z = t.offset.left + t.scrollLeft,
                    C = t.width,
                    r = t.isWindow ? t.scrollLeft : t.offset.left,
                    w = v.left - u.collisionPosition.marginLeft,
                    A = w - r,
                    q = w + u.collisionWidth - C - r,
                    y = u.my[0] === "left" ? -u.elemWidth : u.my[0] === "right" ? u.elemWidth : 0,
                    B = u.at[0] === "left" ? u.targetWidth : u.at[0] === "right" ? -u.targetWidth : 0,
                    s = -2 * u.offset[0],
                    p, x;
                if (A < 0) {
                    p = v.left + y + B + s + u.collisionWidth - C - z;
                    if (p < 0 || p < o(A)) {
                        v.left += y + B + s
                    }
                } else {
                    if (q > 0) {
                        x = v.left - u.collisionPosition.marginLeft + y + B + s - r;
                        if (x > 0 || o(x) < q) {
                            v.left += y + B + s
                        }
                    }
                }
            },
            top: function(u, t) {
                var s = t.within,
                    B = s.offset.top + s.scrollTop,
                    C = s.height,
                    p = s.isWindow ? s.scrollTop : s.offset.top,
                    w = u.top - t.collisionPosition.marginTop,
                    y = w - p,
                    v = w + t.collisionHeight - C - p,
                    z = t.my[1] === "top",
                    x = z ? -t.elemHeight : t.my[1] === "bottom" ? t.elemHeight : 0,
                    D = t.at[1] === "top" ? t.targetHeight : t.at[1] === "bottom" ? -t.targetHeight : 0,
                    r = -2 * t.offset[1],
                    A, q;
                if (y < 0) {
                    q = u.top + x + D + r + t.collisionHeight - C - B;
                    if ((u.top + x + D + r) > y && (q < 0 || q < o(y))) {
                        u.top += x + D + r
                    }
                } else {
                    if (v > 0) {
                        A = u.top - t.collisionPosition.marginTop + x + D + r - p;
                        if ((u.top + x + D + r) > v && (A > 0 || o(A) < v)) {
                            u.top += x + D + r
                        }
                    }
                }
            }
        },
        flipfit: {
            left: function() {
                e.ui.position.flip.left.apply(this, arguments);
                e.ui.position.fit.left.apply(this, arguments)
            },
            top: function() {
                e.ui.position.flip.top.apply(this, arguments);
                e.ui.position.fit.top.apply(this, arguments)
            }
        }
    };
    (function() {
        var t, v, q, s, r, p = document.getElementsByTagName("body")[0],
            u = document.createElement("div");
        t = document.createElement(p ? "div" : "body");
        q = {
            visibility: "hidden",
            width: 0,
            height: 0,
            border: 0,
            margin: 0,
            background: "none"
        };
        if (p) {
            e.extend(q, {
                position: "absolute",
                left: "-1000px",
                top: "-1000px"
            })
        }
        for (r in q) {
            t.style[r] = q[r]
        }
        t.appendChild(u);
        v = p || document.documentElement;
        v.insertBefore(t, v.firstChild);
        u.style.cssText = "position: absolute; left: 10.7432222px;";
        s = e(u).offset().left;
        e.support.offsetFractions = s > 10 && s < 11;
        t.innerHTML = "";
        v.removeChild(t)
    })()
}(jQuery));
(function(d) {
    var b = 0;

    function c(f, g) {
        var e = (f.attr("aria-describedby") || "").split(/\s+/);
        e.push(g);
        f.data("ui-tooltip-id", g).attr("aria-describedby", d.trim(e.join(" ")))
    }

    function a(g) {
        var h = g.data("ui-tooltip-id"),
            f = (g.attr("aria-describedby") || "").split(/\s+/),
            e = d.inArray(h, f);
        if (e !== -1) {
            f.splice(e, 1)
        }
        g.removeData("ui-tooltip-id");
        f = d.trim(f.join(" "));
        if (f) {
            g.attr("aria-describedby", f)
        } else {
            g.removeAttr("aria-describedby")
        }
    }
    d.widget("ui.tooltip", {
        version: "1.10.3",
        options: {
            content: function() {
                var e = d(this).attr("title") || "";
                return d("<a>").text(e).html()
            },
            hide: true,
            items: "[title]:not([disabled])",
            position: {
                my: "left top+15",
                at: "left bottom",
                collision: "flipfit flip"
            },
            show: true,
            tooltipClass: null,
            track: false,
            close: null,
            open: null
        },
        _create: function() {
            this._on({
                mouseover: "open",
                focusin: "open"
            });
            this.tooltips = {};
            this.parents = {};
            if (this.options.disabled) {
                this._disable()
            }
        },
        _setOption: function(e, g) {
            var f = this;
            if (e === "disabled") {
                this[g ? "_disable" : "_enable"]();
                this.options[e] = g;
                return
            }
            this._super(e, g);
            if (e === "content") {
                d.each(this.tooltips, function(i, h) {
                    f._updateContent(h)
                })
            }
        },
        _disable: function() {
            var e = this;
            d.each(this.tooltips, function(h, f) {
                var g = d.Event("blur");
                g.target = g.currentTarget = f[0];
                e.close(g, true)
            });
            this.element.find(this.options.items).addBack().each(function() {
                var f = d(this);
                if (f.is("[title]")) {
                    f.data("ui-tooltip-title", f.attr("title")).attr("title", "")
                }
            })
        },
        _enable: function() {
            this.element.find(this.options.items).addBack().each(function() {
                var e = d(this);
                if (e.data("ui-tooltip-title")) {
                    e.attr("title", e.data("ui-tooltip-title"))
                }
            })
        },
        open: function(f) {
            var e = this,
                g = d(f ? f.target : this.element).closest(this.options.items);
            if (!g.length || g.data("ui-tooltip-id")) {
                return
            }
            if (g.attr("title")) {
                g.data("ui-tooltip-title", g.attr("title"))
            }
            g.data("ui-tooltip-open", true);
            if (f && f.type === "mouseover") {
                g.parents().each(function() {
                    var i = d(this),
                        h;
                    if (i.data("ui-tooltip-open")) {
                        h = d.Event("blur");
                        h.target = h.currentTarget = this;
                        e.close(h, true)
                    }
                    if (i.attr("title")) {
                        i.uniqueId();
                        e.parents[this.id] = {
                            element: this,
                            title: i.attr("title")
                        };
                        i.attr("title", "")
                    }
                })
            }
            this._updateContent(g, f)
        },
        _updateContent: function(j, i) {
            var h, e = this.options.content,
                g = this,
                f = i ? i.type : null;
            if (typeof e === "string") {
                return this._open(i, j, e)
            }
            h = e.call(j[0], function(k) {
                if (!j.data("ui-tooltip-open")) {
                    return
                }
                g._delay(function() {
                    if (i) {
                        i.type = f
                    }
                    this._open(i, j, k)
                })
            });
            if (h) {
                this._open(i, j, h)
            }
        },
        _open: function(i, k, h) {
            var j, g, f, l = d.extend({}, this.options.position);
            if (!h) {
                return
            }
            j = this._find(k);
            if (j.length) {
                j.find(".ui-tooltip-content").html(h);
                return
            }
            if (k.is("[title]")) {
                if (i && i.type === "mouseover") {
                    k.attr("title", "")
                } else {
                    k.removeAttr("title")
                }
            }
            j = this._tooltip(k);
            c(k, j.attr("id"));
            j.find(".ui-tooltip-content").html(h);

            function e(m) {
                l.of = m;
                if (j.is(":hidden")) {
                    return
                }
                j.position(l)
            }
            if (this.options.track && i && /^mouse/.test(i.type)) {
                this._on(this.document, {
                    mousemove: e
                });
                e(i)
            } else {
                j.position(d.extend({
                    of: k
                }, this.options.position))
            }
            j.hide();
            this._show(j, this.options.show);
            if (this.options.show && this.options.show.delay) {
                f = this.delayedShow = setInterval(function() {
                    if (j.is(":visible")) {
                        e(l.of);
                        clearInterval(f)
                    }
                }, d.fx.interval)
            }
            this._trigger("open", i, {
                tooltip: j
            });
            g = {
                keyup: function(m) {
                    if (m.keyCode === d.ui.keyCode.ESCAPE) {
                        var n = d.Event(m);
                        n.currentTarget = k[0];
                        this.close(n, true)
                    }
                },
                remove: function() {
                    this._removeTooltip(j)
                }
            };
            if (!i || i.type === "mouseover") {
                g.mouseleave = "close"
            }
            if (!i || i.type === "focusin") {
                g.focusout = "close"
            }
            this._on(true, k, g)
        },
        close: function(f) {
            var e = this,
                h = d(f ? f.currentTarget : this.element),
                g = this._find(h);
            if (this.closing) {
                return
            }
            clearInterval(this.delayedShow);
            if (h.data("ui-tooltip-title")) {
                h.attr("title", h.data("ui-tooltip-title"))
            }
            a(h);
            g.stop(true);
            this._hide(g, this.options.hide, function() {
                e._removeTooltip(d(this))
            });
            h.removeData("ui-tooltip-open");
            this._off(h, "mouseleave focusout keyup");
            if (h[0] !== this.element[0]) {
                this._off(h, "remove")
            }
            this._off(this.document, "mousemove");
            if (f && f.type === "mouseleave") {
                d.each(this.parents, function(j, i) {
                    d(i.element).attr("title", i.title);
                    delete e.parents[j]
                })
            }
            this.closing = true;
            this._trigger("close", f, {
                tooltip: g
            });
            this.closing = false
        },
        _tooltip: function(e) {
            var g = "ui-tooltip-" + b++,
                f = d("<div>").attr({
                    id: g,
                    role: "tooltip"
                }).addClass("ui-tooltip ui-widget ui-corner-all ui-widget-content " + (this.options.tooltipClass || ""));
            d("<div>").addClass("ui-tooltip-content").appendTo(f);
            f.appendTo(this.document[0].body);
            this.tooltips[g] = e;
            return f
        },
        _find: function(e) {
            var f = e.data("ui-tooltip-id");
            return f ? d("#" + f) : d()
        },
        _removeTooltip: function(e) {
            e.remove();
            delete this.tooltips[e.attr("id")]
        },
        _destroy: function() {
            var e = this;
            d.each(this.tooltips, function(h, f) {
                var g = d.Event("blur");
                g.target = g.currentTarget = f[0];
                e.close(g, true);
                d("#" + h).remove();
                if (f.data("ui-tooltip-title")) {
                    f.attr("title", f.data("ui-tooltip-title"));
                    f.removeData("ui-tooltip-title")
                }
            })
        }
    })
}(jQuery));
(function(a) {
    a.fn.menuAim = function(c) {
        this.each(function() {
            b.call(this, c)
        });
        return this
    };

    function b(n) {
        var h = a(this),
            k = null,
            f = [],
            j = null,
            i = null,
            r = undefined,
            e = a.extend({
                rowSelector: "> li",
                submenuSelector: "*",
                submenuDirection: "right",
                tolerance: 75,
                enter: a.noop,
                exit: a.noop,
                activate: a.noop,
                deactivate: a.noop,
                exitMenu: a.noop,
                activationDelay: 0
            }, n);
        var c = 3,
            l = 300;
        var g = function(u) {
            f.push({
                x: u.pageX,
                y: u.pageY
            });
            if (f.length > c) {
                f.shift()
            }
        };
        var m = function() {
            if (i) {
                clearTimeout(i)
            }
            if (e.exitMenu(this)) {
                if (k) {
                    e.deactivate(k)
                }
                k = null
            }
        };
        var p = function() {
                if (i) {
                    clearTimeout(i)
                }
                e.enter(this);
                q(this)
            },
            o = function() {
                if (r) {
                    clearTimeout(r);
                    r = undefined
                }
                e.exit(this)
            };
        var s = function() {
            d(this)
        };
        var d = function(u) {
            if (u == k) {
                return
            }
            if (e.activationDelay > 0) {
                if (r) {
                    clearTimeout(r)
                }
                r = setTimeout(v, e.activationDelay)
            } else {
                v()
            }

            function v() {
                if (k) {
                    e.deactivate(k)
                }
                e.activate(u);
                k = u
            }
        };
        var q = function(v) {
            var u = t();
            if (u) {
                i = setTimeout(function() {
                    q(v)
                }, u)
            } else {
                d(v)
            }
        };
        var t = function() {
            if (!k || !a(k).is(e.submenuSelector)) {
                return 0
            }
            var y = h.offset(),
                u = {
                    x: y.left,
                    y: y.top
                },
                F = {
                    x: y.left + h.outerWidth(),
                    y: u.y
                },
                H = {
                    x: y.left,
                    y: y.top + h.outerHeight()
                },
                z = {
                    x: y.left + h.outerWidth(),
                    y: H.y
                },
                A = f[f.length - 1],
                E = f[0];
            if (!A) {
                return 0
            }
            if (!E) {
                E = A
            }
            if (e.submenuDirection == "right") {
                F.y -= e.tolerance;
                z.y += e.tolerance
            } else {
                if (e.submenuDirection == "left") {
                    u.y -= e.tolerance;
                    H.y += e.tolerance
                } else {
                    if (e.submenuDirection == "above") {
                        u.x -= e.tolerance;
                        F.x += e.tolerance
                    } else {
                        if (e.submenuDirection == "below") {
                            u.x -= e.tolerance;
                            F.x += e.tolerance
                        }
                    }
                }
            }
            if (E.x < y.left || E.x > z.x || E.y < y.top || E.y > z.y) {
                return 0
            }
            if (j && A.x == j.x && A.y == j.y) {
                return 0
            }

            function B(J, I) {
                return (I.y - J.y) / (I.x - J.x)
            }
            var D = F,
                v = z;
            if (e.submenuDirection == "left") {
                D = H;
                v = u
            } else {
                if (e.submenuDirection == "below") {
                    D = F;
                    v = u
                } else {
                    if (e.submenuDirection == "above") {
                        D = u;
                        v = F
                    }
                }
            }
            var w = B(A, D),
                C = B(A, v),
                G = B(E, D),
                x = B(E, v);
            if (w < G && C > x) {
                j = A;
                return l
            }
            j = null;
            return 0
        };
        h.mouseleave(m).find(e.rowSelector).mouseenter(p).mouseleave(o).click(s);
        a(document).mousemove(g)
    }
})(jQuery);
(function(b) {
    var a = {
        duration: 500,
        cycle: false,
        autoplay: false,
        delay: 3000,
        type: "",
        paging: false,
        changeLinks: true,
        endatfirst: false
    };
    b.fn.contentslider = function(d) {
        var c = b.extend(true, {}, a, d);
        return this.each(function() {
            var t = b(this),
                g = t.find(".contentslider__content"),
                n = g.find(".contentslider__area"),
                V = n.filter(".active"),
                Q = n.first(),
                M = n.last(),
                s, K, X, H, p, L, k = g.data("direction"),
                N = n.length,
                S = false,
                z = n.filter(".active").length === 0 ? true : false,
                o = Modernizr.csstransitions && Modernizr.csstransforms,
                I = 0,
                j;
            if (!t.hasClass("contentslider")) {
                t.addClass("contentslider")
            }
            if (z) {
                Q.addClass("active")
            }
            if (N > 1) {
                if (c.paging === true || c.changeLinks === true) {
                    l(n)
                }
                K.on("click.changeArea", v);
                if (!c.cycle) {
                    G(n, V, p, L)
                }
                if (c.autoplay) {
                    try {
                        t.on("inview.init", function(ab, aa) {
                            if (aa) {
                                m()
                            }
                        })
                    } catch (R) {
                        m()
                    }
                }
            }

            function l(aa) {
                if (c.paging === true) {
                    if (t.find(".paging").length === 0) {
                        Z(aa)
                    }
                    X = t.find(".paging");
                    if (X.find(".paging__area").length > 1) {
                        if (X.find(".paging__control").length == 0) {
                            f(X)
                        }
                        var e = X.find(".paging__control a");
                        y(e, X.find(".paging__area"));
                        G(X.find(".paging__area"), X.find(".paging__area--active"), X.find(".paging__control .paging__prev"), X.find(".paging__control .paging__next"))
                    }
                }
                if (c.changeLinks === true) {
                    if (t.find(".change").length === 0) {
                        A()
                    }
                    H = t.find(".change");
                    p = H.find(".prev");
                    L = H.find(".next")
                }
                s = t.find(".control");
                K = s.find("a").not(".paging__control a")
            }

            function Z(aa) {
                var e = '<ul class="paging control">';
                aa.each(function(ab) {
                    var ad = ab + 1,
                        ac = ab === 0 ? ' class="active"' : "";
                    e += "<li" + ac + '><a href="#">' + ad + "</a></li>"
                });
                e += "</ul>";
                t.append(e)
            }

            function A() {
                t.append(louis.Pattern.returnHtml("contentsliderChangeLinks"))
            }

            function f(e) {
                e.append('<ul class="paging__control"><li class="paging__prev"><a href="#previous"></a><li class="paging__next"><a href="#next"></a></ul>')
            }

            function y(aa, e) {
                aa.on("click", function(ag) {
                    ag.preventDefault();
                    var af = b(this),
                        ad = af.attr("href"),
                        ae = ad == "#previous" ? "prev" : "next",
                        ab = e.filter(".paging__area--active"),
                        ac = J(e, ab, ae);
                    aa.closest("li").removeClass("disabled");
                    Y(ab, ac, ae)
                })
            }

            function J(ad, aa, ac) {
                var ab = ad.index(aa),
                    e;
                if (ac == "prev") {
                    e = ab - 1
                } else {
                    e = ab + 1
                }
                return ad.eq(e)
            }

            function G(ac, e, ab, aa) {
                if (ab === undefined && aa === undefined) {
                    return
                }
                if (W(ac, e)) {
                    ab.addClass("disabled")
                }
                if (D(ac, e)) {
                    aa.addClass("disabled")
                }
            }

            function v(ad) {
                ad.preventDefault();
                var ab = b(ad.delegateTarget),
                    aa = ab.closest("li"),
                    ac = "next";
                if (aa.hasClass("active") || aa.hasClass("disabled")) {
                    return
                }
                if (c.autoplay) {
                    x()
                }
                if (ab.closest(".paging").length > 0) {
                    ac = X.find("li").not(".paging__control li").index(aa)
                } else {
                    if (aa.hasClass("prev")) {
                        ac = "prev"
                    }
                }
                if (X.find(".paging__control").length > 0) {
                    if (ac == "prev" && X.find(".paging__area--active .active").is(":first-child")) {
                        X.find(".paging__prev a").trigger("click")
                    } else {
                        if (ac == "next" && X.find(".paging__area--active .active").is(":last-child")) {
                            X.find(".paging__next a").trigger("click")
                        }
                    }
                }
                T(ac)
            }

            function Y(e, aa, ad) {
                var ab;
                if (Modernizr.csstransforms && Modernizr.csstransitions) {
                    if (ad == "prev") {
                        ab = k ? "slide-out-bottom" : "slide-out-right";
                        aa.addClass(k ? "set-to-top" : "set-to-left")
                    } else {
                        ab = k ? "slide-out-top" : "slide-out-left"
                    }
                    F(e, aa, ab)
                } else {
                    if (ad == "prev") {
                        ab = "100%";
                        var ac = k ? "top" : "left";
                        aa.css(ac, "-100%")
                    } else {
                        ab = "-100%"
                    }
                    h(e, aa, ab)
                }
            }

            function x() {
                if (j !== undefined) {
                    clearInterval(j);
                    setTimeout(function() {
                        i()
                    }, c.duration + 200)
                }
            }

            function m() {
                i();
                t.on("inview", function(ab, aa) {
                    if (aa) {
                        S = false
                    } else {
                        S = true
                    }
                });
                t.off("inview.init");
                if (c.autoplay) {
                    g.on("mouseover", function() {
                        S = true
                    });
                    g.on("mouseout", function() {
                        S = false
                    })
                }
            }

            function i() {
                j = setInterval(function() {
                    if ((c.endatfirst && n.filter(".active").is(Q) && I != 0) || (!c.cycle && n.filter(".active").is(M) && !c.endatfirst)) {
                        clearInterval(j);
                        return
                    }
                    if (!S && !userIsScrolling) {
                        T("next")
                    }
                }, c.delay + c.duration)
            }

            function q() {
                K.off("click.changeArea");
                K.on("click", function(aa) {
                    aa.preventDefault()
                })
            }

            function P() {
                K.on("click.changeArea", v)
            }

            function E() {
                X.find(".active").not(".paging__control li").removeClass("active");
                X.find("li:eq(" + n.index($next) + ")").addClass("active")
            }

            function w(ad) {
                var ac = k ? "slide-out-top" : "slide-out-left",
                    e = o ? ac : (c.type == "main-article-teaser" ? "-99%" : "-100%"),
                    af = n.index(V),
                    ab = W(n, V),
                    ae = D(n, V),
                    aa;
                if (typeof ad === "number") {
                    if (ad == af) {
                        return
                    }
                    $next = n.eq(ad);
                    if (ad < af) {
                        ac = k ? "slide-out-bottom" : "slide-out-right";
                        e = o ? ac : (c.type == "main-article-teaser" ? "99%" : "100%");
                        if (o) {
                            $next.addClass(k ? "set-to-top" : "set-to-left")
                        } else {
                            aa = k ? "top" : "left";
                            $next.css(aa, "-100%")
                        }
                    }
                } else {
                    if (ad === "prev") {
                        if (ab) {
                            if (!c.cycle) {
                                return
                            }
                            $next = M
                        } else {
                            $next = V.prev()
                        }
                        ac = k ? "slide-out-bottom" : "slide-out-right";
                        e = o ? ac : (c.type == "main-article-teaser" ? "99%" : "100%");
                        if (o) {
                            $next.addClass(k ? "set-to-top" : "set-to-left")
                        } else {
                            aa = k ? "top" : "left";
                            $next.css(aa, "-100%")
                        }
                    } else {
                        if (ae) {
                            I = 1;
                            if (!c.cycle && !c.endatfirst) {
                                return
                            }
                            $next = Q
                        } else {
                            if (ab && !c.cycle && c.endatfirst && I > 0) {
                                $next = Q
                            } else {
                                $next = V.next()
                            }
                        }
                    }
                }
                return [$next, e]
            }

            function T(ac) {
                var ad = w(ac);
                if (ad !== undefined) {
                    var aa = ad[0],
                        ab = ad[1],
                        e = D(aa);
                    q();
                    t.addClass("sliding");
                    s.find("li").not(".paging__control li").removeClass("disabled");
                    if (c.paging) {
                        E(aa)
                    }
                    if (o) {
                        F(V, aa, ab, e)
                    } else {
                        h(V, aa, ab, e)
                    }
                }
            }

            function F(e, ab, ac, aa) {
                ab.addClass("prepare-sliding");
                setTimeout(function() {
                    e.add(ab).css({
                        "-webkit-transition-duration": c.duration + "ms",
                        "-moz-transition-duration": c.duration + "ms",
                        "-ms-transition-duration": c.duration + "ms",
                        "transition-duration": c.duration + "ms"
                    }).addClass("sliding " + ac)
                }, 100);
                setTimeout(function() {
                    var ad = b(this);
                    if (k) {
                        B(ad, e, ab, ac, aa)
                    } else {
                        U(ad, e, ab, ac, aa)
                    }
                }, c.duration + 200)
            }

            function U(ad, e, ab, ac, aa) {
                ab.removeClass(ac).removeClass("prepare-sliding");
                if (!c.cycle && aa) {
                    ad.addClass("slide-from-right")
                }
                e.add(ab).removeAttr("style");
                e.removeClass("sliding slide-out-left slide-out-right");
                ab.removeClass("sliding set-to-left");
                if (e.closest(".paging").length == 0) {
                    C(ab)
                } else {
                    u(e, ab)
                }
            }

            function B(ad, e, ab, ac, aa) {
                ab.removeClass(ac).removeClass("prepare-sliding");
                if (!c.cycle && aa) {
                    ad.addClass("slide-from-bottom")
                }
                e.add(ab).removeAttr("style");
                e.removeClass("sliding slide-out-top slide-out-bottom");
                ab.removeClass("sliding set-to-top");
                if (e.closest(".paging").length == 0) {
                    C(ab)
                } else {
                    u(e, ab)
                }
            }

            function h(e, ab, ac, aa) {
                console.log("louis.Contentslider: changeAreaWithJS()");
                if (k) {
                    O(e, ab, ac, aa)
                } else {
                    r(e, ab, ac, aa)
                }
            }

            function r(e, ab, ac, aa) {
                e.animate({
                    left: ac
                }, c.duration, function() {
                    var ad = b(this);
                    ad.css("left", "100%");
                    if (!c.cycle && aa) {
                        ad.css("left", "100%")
                    }
                });
                ab.animate({
                    left: "0%"
                }, c.duration + 1, function() {
                    if (e.closest(".paging").length == 0) {
                        C(ab)
                    } else {
                        u(e, ab)
                    }
                })
            }

            function O(e, ab, ac, aa) {
                e.animate({
                    top: ac
                }, c.duration, function() {
                    var ad = b(this);
                    ad.css("top", "200%");
                    if (!c.cycle && aa) {
                        ad.css("top", "200%")
                    }
                });
                ab.animate({
                    top: "0%"
                }, c.duration + 1, function() {
                    if (e.closest(".paging").length == 0) {
                        C(ab)
                    } else {
                        u(e, ab)
                    }
                })
            }

            function W(aa, e) {
                return aa.index(e) === 0
            }

            function D(aa, e) {
                return aa.index(e) === aa.length - 1
            }

            function C(e) {
                t.removeClass("sliding");
                V.removeClass("active");
                e.addClass("active");
                V = n.filter(".active");
                if (!c.cycle) {
                    G(n, V, p, L)
                }
                P()
            }

            function u(e, aa) {
                e.removeClass("paging__area--active");
                aa.addClass("paging__area--active");
                G(aa.closest(".paging__content").find(".paging__area"), aa, aa.closest(".paging").find(".paging__prev"), aa.closest(".paging").find(".paging__next"))
            }
        })
    }
}(jQuery));
