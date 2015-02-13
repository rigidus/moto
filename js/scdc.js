var louis = {},
    shared = {},
    $window = $(window),
    $document = $(document),
    $html, $body, $footer, $overlayBg, files = {},
    runningXhr = [],
    userIsScrolling = false,
    lang, supportsHtml5InputTypeValidation = false,
    context = louis,
    flyouts = {};
$document.ready(function() {
    var e = shared.Helper.getCdnUrl(),
        d = "/js",
        a = "/layout",
        c = a + "/swf",
        b = {
            "#js__requestData-header": [louis.RequestData.Header],
            "#js__requestData-bikedb": [shared.RequestData.BikeDb],
            "#js__requestData-checkout": [louis.RequestData.Checkout],
            "#js__requestData-standard": [shared.RequestData.Standard],
            "#js__articleDetail": [louis.ArticleDetail],
            "#js__checkout": [shared.Checkout],
            "#js__service": [shared.Service, louis.Service],
            "#js__branchNetwork": [shared.BranchNetwork, louis.BranchNetwork],
            "#js__helmetAdvisor": [louis.HelmetAdvisor],
            "#mediacenter": [louis.MediaCenter]
        };
    $html = $("html");
    $body = $("body");
    $footer = $(".footer");
    $overlayBg = $(".overlay-bg");
    lang = $html.attr("lang") || "de";
    files = {
        js: {
            zoomify: d + shared.Helper.getFileName("ZoomifyImageViewer.js"),
            videoJs: d + shared.Helper.getFileName("video.js"),
            jQuery: e + d + shared.Helper.getFileName("jquery-1.10.2.js"),
            branchNetworkIframe: e + d + shared.Helper.getFileName("shared.BranchNetwork.Iframe.js")
        },
        image: {
            transparency: e + a + "/transparency.gif",
            placeholder298: e + a + "/placeholder298x298.jpg",
            mapsMarker: e + a + "/marker.png",
            mapsMarkerShadow: e + a + "/marker-shadow.png",
            mapsMarkerDetail: e + a + "/marker-detail.png",
            mapsMarkerDetailShadow: e + a + "/marker-detail-shadow.png",
            zoomifySkin: e + a + "/zoomify"
        },
        swf: {
            videoJs: e + c + "/video-js.swf",
            zoomify: e + c + "/ZoomifyViewer.swf"
        }
    };
    if (!$html.data("development")) {
        console.log = function() {}
    }
    if ($body.length > 0) {
        shared.Common.init();
        louis.Common.init();
        louis.Misc.init($body);
        shared.Misc.init($body);
        shared.Forms.init($body);
        louis.Forms.init($body)
    }
    $.each(b, function(f, g) {
        var h = $(f);
        if (h.length > 0) {
            $.each(g, function(j) {
                g[j].init(h)
            })
        }
    })
});
louis.Common = (function(d) {
    var b;

    function o() {
        var x = d("#header-search-q"),
            w = d(".main-nav > .container > ul"),
            v = d(".home"),
            s = d(".bikedb-select-flyout"),
            t = s.find(".action-icon--close"),
            u = d(".meta-nav .language-select"),
            z = u.find(".language-select__item.active"),
            y = location.hash;
        r();
        j();
        a();
        l(y);
        c();
        if (!$body.hasClass("popup-window") && !Modernizr.touch && d(".intranet").length == 0) {
            g()
        }
        if (x.length > 0) {
            h(x, v, y);
            shared.AutoSuggest.init(x)
        }
        if (w.length > 0 && !Modernizr.touch) {
            k(w)
        }
        if (u.length > 0 && z.length > 0 && Modernizr.touch) {
            q(u, z)
        }
        if (t.length > 0) {
            m(t)
        }
    }

    function k(s) {
        console.log("Common: initMenuAim()");
        if (s.length > 0) {
            s.menuAim({
                activate: n,
                deactivate: e,
                exitMenu: function(t) {
                    if (!b) {
                        b = setTimeout(function() {
                            f(t)
                        }, 200);
                        return false
                    }
                    return true
                },
                submenuDirection: "below",
                tolerance: 0,
                activationDelay: 200,
                enter: function() {
                    clearTimeout(b);
                    b = null
                }
            })
        }
    }

    function m(s) {
        console.log("Common: addMyBikeFlyoutCloseListener()");
        s.on("click", function(t) {
            t.preventDefault();
            i()
        })
    }

    function j() {
        console.log("Common: addToggleFooterButtonListener()");
        var s = $footer.find(".js__footerToggle");
        s.on("click", function(t) {
            t.preventDefault();
            p(s)
        })
    }

    function q(t, s) {
        console.log("Common: addLanguageSelectListener()");
        s.on("click.showLanguages", function(u) {
            if (!t.hasClass("active")) {
                u.preventDefault();
                u.stopPropagation();
                t.addClass("active")
            }
        });
        t.find("span").on("click", function() {
            t.removeClass("active")
        })
    }

    function g() {
        console.log("Common: setBackgroundImage()");
        var s;
        if ($body.data("background-image")) {
            $body.prepend(shared.Misc.replacePlaceholderInString(louis.Pattern.returnHtml("backgroundImage"), [$body.data("background-image")]));
            s = d("#js__bg");
            if ($footer.length > 0 && $body.data("background-attachment") !== "scroll") {
                s.find("img").on("load", function() {
                    louis.Background.init(s)
                })
            }
        }
    }

    function i() {
        console.log("Common: myBikeFlyoutCloseBehaviour()");
        var t = d("#mybike-flyout-list"),
            s = d("#mybike-flyout-form");
        if (t.find(".bike").length > 1 && t.hasClass("hidden")) {
            s.addClass("hidden");
            t.removeClass("hidden")
        }
    }

    function c() {
        console.log("Common: detectScrolling()");
        var s;
        $window.on("scroll", function() {
            $body.attr("style", "pointer-events: none !important");
            userIsScrolling = true;
            clearTimeout(s);
            s = setTimeout(function() {
                $body.removeAttr("style");
                userIsScrolling = false
            }, 250)
        })
    }

    function r() {
        console.log("Common: checkEnvironment()");
        if (!Modernizr.input.placeholder) {
            d("html").addClass("supports-no-placeholder")
        }
    }

    function l(t) {
        console.log("Common: checkForHash()");
        var s = d(t);
        if (s.length > 0) {
            if (s.hasClass("tab")) {
                if (s.closest(".js__tab-system").data("sethash") == true) {
                    shared.Misc.changeTab(s);
                    louis.Misc.jumpToContent(s)
                }
            } else {
                if (s.hasClass("overlay-container")) {
                    if (s.is("#mediacenter")) {
                        d(".js__openMediaCenter:eq(0)").trigger("click")
                    } else {
                        louis.Misc.positionOverlay(s)
                    }
                } else {
                    if (d('a[href="' + t + '"].js__openOverlay').length > 0) {
                        louis.Misc.openOverlay(d('a[href="' + t + '"]:eq(0)'))
                    }
                }
            }
        }
    }

    function h(t, s, u) {
        console.log("Common: focusSearchInput()");
        if (!Modernizr.touch && s.length > 0 && u == "") {
            t.focus()
        }
    }

    function a() {
        console.log("Common: checkForActiveOverlay()");
        if (d(".overlay-container.active").length > 0 && !$overlayBg.hasClass("active")) {
            $overlayBg.addClass("active")
        }
    }

    function n(y) {
        console.log("Common: activateMenuFlyout()");
        var v = d(y);
        if (v.hasClass("flyout-parent")) {
            if (v.hasClass("main-nav__item--themenWelten")) {
                var t = 97;
                var s = v.find("li").length;
                var x = Math.round(t / s);
                var B = $body.find(".container");
                var A = (Math.round(B.width() / 2));
                var z = v.find(".nav-flyout");
                var w = (Math.round(z.width() / 2));
                var u = A - w - x;
                if (u > 0) {
                    z.css("left", u + "px")
                }
            }
            v.addClass("flyout--hover")
        }
    }

    function f(t) {
        console.log("Common: triggerLeaveMenu()");
        var s = d(t);
        s.trigger("mouseleave")
    }

    function e(t) {
        console.log("Common: deactivateMenuFlyout()");
        var s = d(t);
        s.removeClass("flyout--hover")
    }

    function p(u) {
        var t, s = u.find(".button__text");
        if ($footer.hasClass("footer--full-content")) {
            console.log("Common: footerToggle() -> close");
            s.html(local.footerToggleMore);
            $footer.removeClass("footer--full-content").addClass("footer--less-content");
            t = "less"
        } else {
            console.log("Common: footerToggle() -> open");
            s.html(local.footerToggleLess);
            $footer.removeClass("footer--less-content").addClass("footer--full-content");
            t = "full"
        }
        shared.Helper.setCookie("footer", t)
    }
    return {
        init: o
    }
}(jQuery));
louis.Forms = (function(d) {
    function q(y) {
        var B = y.find(".js__clearForm"),
            v = y.find(".js__handleViaAjax"),
            C = y.find(".js__fillViaJS"),
            z = y.find(".hide-label"),
            w = y.find(".supports-no-placeholder .placeholder-fix, .hide-label"),
            x = y.find(".js__selectOptionElement"),
            A = y.find('input[name*="qty"]');
        if (x.length > 0) {
            d.each(x, function() {
                var D = d(this);
                r(D, D.closest("form"))
            });
            n(x)
        }
        if (A.length > 0) {
            j(A)
        }
        if (B.length > 0) {
            s(B)
        }
        if (v.length > 0) {
            g(v)
        }
        if (C.length > 0) {
            o(C)
        }
        if (z.length > 0 && d(".supports-no-placeholder").length > 0) {
            t(z)
        }
        if (w.length > 0) {
            f(w)
        }
        louis.Forms.Additional.init(y)
    }

    function k(v) {
        console.log("Forms: addChangeTypeNumberToTypeText()");
        v.on("focus", function() {
            var x = d(this),
                w = x.prop("type");
            h(x, "text");
            x.one("blur", function() {
                h(x, w);
                x.trigger("change")
            })
        })
    }

    function j(v) {
        console.log("Forms: addQtyInputsListener()");
        v.on("focus", function(w) {
            shared.Forms.selectInput(d(this))
        })
    }

    function n(v) {
        console.log("Forms: addSelectOptionElementListener()");
        v.on("change", function() {
            var w = d(this);
            r(w, w.closest("form"))
        })
    }

    function g(x) {
        console.log("Forms: addHandleViaAjaxListener()");
        var w = x[0].tagName == "FORM" ? x : x.closest("form"),
            v = x.hasClass("inner-form") ? x : null;
        w.on("submit.xhr", function(D) {
            var z = d(".clicked-button"),
                B = d('[type="submit"][name="' + z.prop("name") + '"]');
            if (B.closest(".js__handleViaAjax").length > 0) {
                D.preventDefault();
                var C = d(this),
                    y = v || C;
                if (C.hasClass("js__formValidation")) {
                    (function A() {
                        if (y.data("validation-done")) {
                            if (!y.data("invalid")) {
                                u(C)
                            }
                        } else {
                            setTimeout(function() {
                                A()
                            }, 50)
                        }
                    }())
                } else {
                    u(C)
                }
            }
        })
    }

    function m(v) {
        console.log("Forms: removeHandleViaAjaxListener()");
        v.off("submit.xhr")
    }

    function s(v) {
        console.log("Forms: addClearFormListener()");
        v.on("click", function() {
            a(v.closest("form"))
        })
    }

    function o(v) {
        console.log("Forms: addFillViaJSListener()");
        v.on("click", function(x) {
            x.preventDefault();
            var w = d(this);
            if (!w.data("ajax")) {
                c(w)
            }
        })
    }

    function h(w, v) {
        console.log("Forms: changeTypeOfInputElement()");
        w.prop("type", v)
    }

    function r(C, D) {
        console.log("Forms: selectOptionElement()");
        var y = C[0].tagName == "SELECT" ? C.find("option:selected").data("select-option-element") : C.data("select-option-element"),
            v = d("#" + y),
            B = v.attr("name"),
            A = D.find('[name="' + B + '"]'),
            w = A.filter(":visible"),
            x = w.length;
        (function z() {
            if (A.filter(":checked").length === 0) {
                v.prop("checked", true).trigger("change")
            } else {
                if (x > 1) {
                    return
                }
                if (x === 1) {
                    A.each(function() {
                        d(this).prop("checked", false)
                    });
                    z()
                }
            }
        }())
    }

    function t(v) {
        console.log("Forms: addPlaceholderFix()");
        d.each(v, function() {
            var w = d(this),
                y = w.find("input"),
                x = y.prop("placeholder");
            if (x && x != "") {
                w.prepend("<label>" + x + "</label>")
            }
        })
    }

    function u(E, C) {
        console.log("Forms: handleViaAjax()");
        var y = E.find('[type="submit"]:visible:eq(0)'),
            w = E.find('[type="submit"], [type="button"], .submit-button'),
            z = C ? C : E,
            A = E.serializeArray(),
            v = E.attr("action"),
            x = d("#" + E.data("target")),
            B = E.attr("method"),
            D;
        if (runningXhr.length > 0) {
            shared.Misc.cancelRunningXhrs()
        }
        if (E.data("loading-mode") == "overlay") {
            $overlayBg.addClass("active overlay-content-loading");
            $body.addClass("overlay-active")
        } else {
            y.addClass("button--loading");
            w.not(".button--loading").prop("disabled", true).addClass("disabled")
        }
        E.find(".error").remove();
        D = d.ajax({
            type: B,
            url: v,
            data: A,
            success: function(H, F, J) {
                var G = J.getResponseHeader("content-type") || "",
                    I = H;
                if (G.indexOf("html") > -1) {
                    I = JSON.parse(I)
                }
                b(z, x, I)
            },
            error: function(F) {
                if (F.readyState != 0) {
                    louis.Misc.createOverlay("systemMessage", ["caution", "attention", local.standardErrorMessage])
                }
            },
            complete: function() {
                w.not(".button--loading").prop("disabled", false).removeClass("disabled");
                y.removeClass("button--loading");
                E.find('.submit-button[type="submit"]').prop("type", "button");
                shared.Forms.removeHiddenSubmit(E);
                runningXhr = shared.Helper.removeItemFromArray(runningXhr, D)
            }
        });
        runningXhr.push(D)
    }

    function b(x, w, z) {
        console.log("Forms: handleSuccessfulAjaxResponse()");
        if (z.closeOverlay) {
            var v = false;
            if (z.newOverlay) {
                v = true
            }
            louis.Misc.closePopup(x.closest(".popup"), v)
        }
        x.find(".js__getNewCaptcha").trigger("click");
        if (z.errors) {
            shared.Forms.Validation.addErrors(x, z.errors);
            shared.Forms.Validation.addErrorListenerAfterClientSideValidation(x)
        }
        if (z.modifyFormElement) {
            e(x, z.modifyFormElement)
        }
        if (z.clearForm) {
            a(x)
        }
        if (z.html) {
            if (z.newOverlay) {
                louis.Misc.createNewOverlay(z.html)
            } else {
                i(w, z.html)
            }
        }
        if (z.modifyHtmlElement) {
            shared.Misc.modifyHtmlElement(z.modifyHtmlElement)
        }
        if (typeof z.pageReload !== "undefined") {
            if (z.pageReload == true) {
                shared.Misc.reloadPageWithParam()
            }
        }
        shared.Forms.removeHiddenSubmit(x);
        if (typeof z.ga !== "undefined") {
            var A = null,
                C = null,
                y = null,
                B = null;
            if (z.ga.category) {
                A = z.ga.category
            }
            if (z.ga.action) {
                C = z.ga.action
            }
            if (z.ga.label) {
                y = z.ga.label
            }
            if (z.ga.value) {
                B = z.ga.value
            }
            if (A != null && C != null) {
                shared.Misc.sendGoogleAnalyticsEvents(A, C, y, B)
            }
        }
    }

    function i(v, w) {
        console.log("Forms: keepOverlay()");
        if (w !== null) {
            v.html(w);
            louis.Misc.init(v);
            louis.Forms.init(v);
            if (typeof louis.ArticleDetail != "undefined") {
                louis.ArticleDetail.init(v)
            }
            if (typeof shared.Checkout != "undefined") {
                shared.Checkout.init(v)
            }
        }
    }

    function e(w, v) {
        d.each(v, function(y, z) {
            var x = w.find('[name="' + y + '"]');
            x.val(z)
        })
    }

    function c(w) {
        console.log("Forms: fillViaJS()");
        var v = d(w.attr("href"));
        v.find(".js__fillViaJS-item").each(function() {
            var A = d(this),
                y = A.data("replace"),
                z = typeof w.data(A.data("get")) !== "undefined" ? w.data(A.data("get")) : "",
                x = A.data("initial-text") || "";
            if (typeof z === "string") {
                z = z.replace("&quot;", '"')
            }
            if (y == "inline") {
                A.html(z + x)
            } else {
                A.prop(y, z)
            }
        })
    }

    function p(w) {
        console.log("Forms: getNewCaptcha()");
        var v = w.closest(".captcha-image"),
            x = v.find("img"),
            y = '<p class="error">' + local.standardErrorMessage + "</p>";
        v.find(".input-container").append('<div class="loading-captcha">Loading</div>');
        v.addClass("captcha-image--loading");
        v.find(".error").remove();
        d.ajax({
            url: w.attr("href"),
            dataType: "json",
            success: function(z) {
                if (z.length != 0) {
                    x.prop("src", z.src);
                    v.find('input[type="hidden"]').val(z.id);
                    v.find('input[type="text"]').val("");
                    x.on("load", function() {
                        v.find(".loading-captcha").remove().end().removeClass("captcha-image--loading")
                    })
                } else {
                    v.append(y);
                    v.find(".loading-captcha").remove().end().removeClass("captcha-image--loading")
                }
            },
            error: function() {
                v.append(y);
                v.find(".loading-captcha").remove().end().removeClass("captcha-image--loading")
            }
        })
    }

    function a(v) {
        console.log("Forms: clearForm()");
        if (v.attr("data-additional-validation")) {
            v.data("additional-validation-done", true);
            v.data("additional-invalid", false)
        }
        v.find("input, select, textarea").off("keyup.regex change.regex keyup.empty change.empty change.error keyup.error");
        d.each(v.find('input.form-element[type!="hidden"], textarea'), function() {
            d(this).val("")
        });
        v.find(".input-error").removeClass("input-error");
        v.find(".error").remove();
        v.find(".validation-explanation--static").addClass("hidden");
        v.find(".validation-explanation--dynamic").remove();
        d.each(v.find("select"), function() {
            var x = d(this),
                w = x.find("option[data-preselected]");
            if (w.length > 0) {
                w.prop("selected", true)
            } else {
                x.find("option:eq(0)").prop("selected", true)
            }
        });
        d.each(v.find("input[type=checkbox][data-preselected], input[type=radio][data-preselected]"), function() {
            var w = d(this);
            w.prop("checked", true).trigger("change")
        })
    }

    function f(v) {
        console.log("Forms: hideLabels()");
        v.each(function() {
            var x = d(this),
                y = x.find("input"),
                w = x.find("label");
            if (y.val().length > 0) {
                w.addClass("hidden")
            }
            w.on("click", function() {
                y.focus()
            });
            y.on("focus keydown keyup change", function(z) {
                if (y.val() != "") {
                    w.addClass("hidden");
                    x.removeClass("hide-label--input-focused")
                } else {
                    w.removeClass("hidden");
                    x.addClass("hide-label--input-focused")
                }
            });
            y.on("blur", function() {
                x.removeClass("hide-label--input-focused")
            })
        })
    }

    function l(w) {
        console.log("louis.Forms: openFormSectionOnError()");
        var v = w.closest(".closed:not(.sliding)");
        if (v.length > 0) {
            v.find(".js__toggleFormSection-link").trigger("click")
        }
    }
    return {
        init: q,
        handleSuccessfulAjaxResponse: b,
        addHandleViaAjaxListener: g,
        removeHandleViaAjaxListener: m,
        openFormSectionOnError: l
    }
}(jQuery));
louis.Forms.Additional = (function(d) {
    var x, i, a = [];

    function q(J) {
        var E = d(".helmet-advisor"),
            C = E.find("form"),
            D = E.find(".street-type"),
            G = D.find("input"),
            F = D.find(".result__total"),
            B = D.find(".result__todo"),
            A = J.find(".js__currencyCalculator");
        if (A.length > 0) {
            l(A)
        }
        if (G.length > 0) {
            g(C, G, F, B, true);
            m(C, G, F, B)
        }
        if (J.find(".js__chooseAnswerType").length > 0) {
            var I = J.find(".js__chooseAnswerType").closest("form"),
                H = {
                    form: I,
                    answerType: I.find(".callback-by"),
                    chooseAnswerType: I.find('input[name="answer_type"]'),
                    choosePeriod: I.find(".choose-period"),
                    selects: {
                        all: I.find(".choose-period select"),
                        day: I.find('select[name="callback_time[day]"]'),
                        from: {
                            hour: I.find('select[name="callback_time[from_hour]"]'),
                            minute: I.find('select[name="callback_time[from_minute]"]')
                        },
                        to: {
                            hour: I.find('select[name="callback_time[to_hour]"]'),
                            minute: I.find('select[name="callback_time[to_minute]"]')
                        }
                    },
                    submit: I.find('[type="submit"]')
                };
            x = parseInt(I.data("minperiod"), 10);
            i = parseInt(I.data("todayplushours"), 10);
            e(H);
            c(H);
            t(H);
            v(H)
        }
    }

    function l(A) {
        console.log("Forms.Additional: addConvertPriceListener()");
        var B = true;
        A.find(".button").on("click", function(D) {
            D.preventDefault();
            (function C() {
                setTimeout(function() {
                    if (A.data("validation-done")) {
                        if (!A.data("invalid")) {
                            h(A, B);
                            B = false
                        }
                    } else {
                        C()
                    }
                }, 10)
            }())
        })
    }

    function m(A, C, B, D) {
        console.log("Forms.Additional: addStreetTypeTotalListener()");
        C.on("change keyup", function() {
            g(A, C, B, D, true)
        });
        A.find('[type="submit"]').on("click", function() {
            g(A, C, B, D, false)
        })
    }

    function t(A) {
        console.log("Forms.Additional: addCallbackByListener()");
        A.chooseAnswerType.on("change", function() {
            r(d(this), A)
        })
    }

    function e(A) {
        console.log("Forms.Additional: addChoosePeriodListener()");
        A.selects["day"].on("change.changeDay", function() {
            var C = d(this);
            if (C.find("option:selected").data("today") == true) {
                currentTime = new Date();
                var B = y(currentTime);
                w(B, A)
            } else {
                n(A.selects);
                j(A.selects["from"]);
                if (u(A.selects)) {
                    k(A)
                }
            }
        });
        d.each(A.selects["from"], function() {
            this.on("change.changeBegin", function() {
                currentTime = new Date();
                if (u(A.selects)) {
                    k(A)
                }
            })
        })
    }

    function c(A) {
        console.log("Forms.Additional: addValidateChoosePeriodListener()");
        A.submit.on("click", function(C) {
            C.preventDefault();
            if (A.form.hasClass("js__formValidation")) {
                (function B() {
                    if (A.form.data("validation-done")) {
                        if (shared.Forms.Validation.checkIfValidationIsRequired(A.selects["day"])) {
                            o(A)
                        } else {
                            A.form.data("additional-invalid", false)
                        }
                    } else {
                        B()
                    }
                }())
            } else {
                o(A)
            }
        })
    }

    function h(P, E) {
        console.log("Forms.Additional: convertPrice()");
        if (!E) {
            b(a)
        }
        var C = d("#currency-calculator__from-to"),
            A = C.find("option:selected"),
            I = d("#currency-calculator__from"),
            G = d("#label-currency-calculator__from"),
            H = d("#currency-calculator__to"),
            B = d("#label-currency-calculator__to"),
            D = P.data("separator"),
            F = parseFloat(A.val()),
            M = A.data("from"),
            L = A.data("to"),
            O, K = I.val().trim();
        K = K.replace(D, ".");
        (function N() {
            var Q = K.match(/\.|,/g);
            if (Q !== null && Q.length > 1) {
                K = K.replace(/\.|,/, "");
                N()
            }
        }());
        var J = parseFloat(K).toFixed(2).toString().replace(/\.|,/, D);
        I.val(J);
        O = parseFloat(K) * F;
        O = O.toFixed(2);
        O = O.toString().replace(".", D);
        H.val(O);
        G.html(M);
        B.html(L + "*");
        a.amount = P.data("amount");
        a.value = J;
        a.from = M;
        a.converted = O;
        a.to = L
    }

    function b(A) {
        console.log("Forms.Additional: addConversionToList()");
        var D = "<li><span>" + A.value + " " + A.from + "</span> <span>тЙИ " + A.converted + " " + A.to + "</span></li>",
            C = d(".currency-calculator__previous-conversions__list"),
            B = C.find("ul");
        if (B.find(".noPreviousConversions").length > 0) {
            B.html(D)
        } else {
            if (B.find("li").length == A.amount) {
                B.find("li:eq(0)").remove()
            }
            B.append(D)
        }
        C.removeClass("hidden");
        A = []
    }

    function g(A, D, B, F, G) {
        console.log("Forms.Additional: calcTotal()");
        if (A.find(".input-container .error").length > 0) {
            return
        }
        var E = 0;
        D.each(function() {
            var H = parseInt(d(this).val(), 10);
            if (isNaN(H)) {
                H = 0
            }
            E += H
        });
        if (isNaN(E)) {
            E = 0
        }
        B.html(E);
        F.html(100 - E);
        if (E > 100) {
            A.data("additional-invalid", true);
            B.add(F).addClass("attention").removeClass("important-positive");
            if (!G) {
                var C = JSON.parse('{ "' + D.filter(":eq(0)").attr("name") + '": { "helmetAdvisorNot100percent": "' + local.helmetAdvisorNot100percent + '" } }');
                shared.Forms.Validation.addErrors(A, C)
            }
        } else {
            A.data("additional-invalid", false);
            if (E == 100) {
                B.add(F).addClass("important-positive").removeClass("attention")
            } else {
                B.add(F).removeClass("attention important-positive")
            }
            shared.Forms.Validation.removeErrors(D, D.filter(":eq(0)").closest(".input-container-group"), "helmetAdvisorNot100percent")
        }
        A.data("additional-validation-done", true)
    }

    function r(A, B) {
        console.log("Forms.Additional: callbackBy()");
        if (A.val() === "phone") {
            B.form.data("additional-validation-done", false);
            v(B)
        } else {
            B.form.data("additional-invalid", false).data("additional-validation-done", true);
            B.answerType.find(".input-error").removeClass("input-error").end().find(".error").remove()
        }
    }

    function o(B) {
        console.log("Forms.Additional: validateChoosePeriod()");
        var A;
        if (f(B.selects) < x) {
            if (x == 60) {
                A = local.callbackMinOneHour
            } else {
                A = shared.Misc.replacePlaceholderInString(local.callbackMin, [x])
            }
            if (B.choosePeriod.find(".error").length === 0) {
                B.choosePeriod.append('<ul class="error">' + A + ".</ul>")
            }
            B.selects["all"].on("change.revalidate", function() {
                o(B)
            });
            B.selects["all"].each(function() {
                var C = d(this);
                if (C.attr("name") !== "answer_day") {
                    C.addClass("input-error")
                }
            });
            B.form.data("additional-invalid", true)
        } else {
            B.choosePeriod.find(".error").remove();
            B.selects["all"].removeClass("input-error");
            B.form.data("additional-invalid", false)
        }
        B.form.data("additional-validation-done", true)
    }

    function v(B) {
        console.log("Forms.Additional: initChoosePeriod()");
        currentTime = new Date();
        B.selects["day"].find("option:first").prop("selected", true);
        if (B.selects["day"].find("option:selected").data("today") === true) {
            var A = y(currentTime);
            w(A, B)
        } else {
            j(B.selects["from"]);
            if (u(B.selects)) {
                k(B)
            }
        }
    }

    function n(A) {
        console.log("Forms.Additional: enableAllOptions()");
        A.all.find("option").prop("disabled", false)
    }

    function j(A) {
        console.log("Forms.Additional: setEarliestPossiblePeriodBegin()");
        A.hour.find("option:not(:disabled):eq(0)").prop("selected", true);
        A.minute.find("option:eq(0)").prop("selected", true)
    }

    function f(C) {
        console.log("Forms.Additional: getDifferenceBetweenStartAndEnd()");
        var B = parseInt(C.from["hour"].val(), 10) * 60,
            H = parseInt(C.from["minute"].val(), 10),
            A = parseInt(C.to["hour"].val(), 10) * 60,
            G = parseInt(C.to["minute"].val(), 10),
            F = B + H,
            E = A + G,
            D = E - F;
        return D
    }

    function p(A, B) {
        console.log("Forms.Additional: setPeriodBeginHour()");
        B.selects["from"]["hour"].find('option[value="' + A + '"]').prop("selected", true)
    }

    function u(A) {
        console.log("Forms.Additional: checkIfChosenPeriodIsTooShort()");
        if (f(A) < x) {
            return true
        }
    }

    function z(B) {
        console.log("Forms.Additional: setPeriodBeginMinute()");
        var A = s();
        B.selects["from"]["minute"].find('option[value="' + A + '"]').prop("selected", true)
    }

    function k(F) {
        console.log("Forms.Additional: setPeriodEndRelatedToPeriodBegin()");
        var B = parseInt(F.selects["from"]["hour"].prop("value"), 10),
            D = parseInt(F.selects["from"]["minute"].prop("value"), 10),
            A = Math.floor(x / 60),
            C = D + (x % 60),
            E;
        if (C > 59) {
            A++;
            C %= 60
        }
        if (C === 0) {
            C = "00"
        }
        toHour = B + A;
        E = F.selects["to"]["hour"].find('option[value="' + toHour + '"]');
        if (E.length > 0) {
            E.prop("selected", true);
            F.selects["to"]["minute"].find('option[value="' + C + '"]').prop("selected", true);
            F.choosePeriod.find(".error").remove().end().find(".input-error").removeClass("input-error")
        } else {
            o(F)
        }
    }

    function s() {
        console.log("Forms.Additional: getNextQuarter()");
        var B = parseInt(currentTime.getMinutes(), 10),
            A;
        if (B > 45) {
            A = 0
        } else {
            if (B > 30) {
                A = 45
            } else {
                if (B > 15) {
                    A = 30
                } else {
                    A = 15
                }
            }
        }
        return A
    }

    function y(B) {
        console.log("Forms.Additional: getMinimumHour()");
        var D = B.getHours(),
            C = B.getMinutes(),
            A;
        A = D + i;
        if (C > 45) {
            A++
        }
        return A
    }

    function w(A, B) {
        console.log("Forms.Additional: disableHours()");
        d.each(B.selects["from"]["hour"].find("option"), function() {
            var C = d(this);
            if (parseInt(C.val(), 10) < A) {
                C.prop("disabled", true)
            }
        });
        d.each(B.selects["to"]["hour"].find("option"), function() {
            var C = d(this);
            if (parseInt(C.val(), 10) <= A) {
                C.prop("disabled", true)
            }
        });
        p(A, B);
        z(B);
        k(B)
    }
    return {
        init: q
    }
}(jQuery));
louis.Misc = (function(x) {
    function K(ab) {
        var O = ab.find(".js__openOverlay"),
            Z = ab.find(".js__tab-system .tab-navigation a"),
            Y = ab.find(".js__changeSearchQuery"),
            V = ab.find(".mediacenter-thumbs"),
            aa = ab.find(".main-article-teaser"),
            U = ab.find(".js__setLinkViaSelect select"),
            ac = ab.find(".js__openPopup"),
            ag = ab.find(".contentslider").add(V).add(aa),
            Q = ab.find(".action-icon--close").add(".js__closePopup"),
            N = ab.find(".article-item--grid"),
            ae = ab.find(".js__openLinkInParent"),
            T = ab.find(".js__printPage"),
            X = ab.find(".compare"),
            W = ab.find(".js__toggleFormSection"),
            P = ab.find("figcaption"),
            ad = ab.find("[data-autofocus]"),
            R = ab.find(".js__arrangeItems"),
            af = ab.find(".js__closeWindow"),
            // S = ab.find(".lazy-load, .article-list"),
            ah = ab.find(".user-nav__flyout, .user-nav .flyout-parent .nav-button, .show-flyout");
        f(ab);
        if (ad.length > 0) {
            shared.Misc.setFocus(ad)
        }
        if (ag.length > 0) {
            k(aa)
        }
        if (R.length > 0) {
            c(R)
        }
        if (X.length > 0) {
            j(X)
        }
        if (P.length > 0) {
            v(P)
        }
        // if (S.length > 0) {
        //     shared.Misc.addLazyLoadListener(S)
        // }
        if (N.length > 0) {
            i(N)
        }
        if (O.length > 0) {
            a(O)
        }
        if (ae.length > 0) {
            s(ae)
        }
        if (Q.length > 0) {
            l(Q)
        }
        if (af.length > 0) {
            e(af)
        }
        if (Z.length > 0) {
            F(Z)
        }
        if (Y.length > 0) {
            w(Y)
        }
        if (ac.length > 0) {
            C(ac)
        }
        if (U.length > 0) {
            y(U)
        }
        if (W.length > 0) {
            A(W)
        }
        if (T.length > 0) {
            n(T)
        }
        if (ah.length > 0) {
            o(ah)
        }
    }

    function c(N) {
        console.log("Misc: initArrangeItems()");
        N.each(function() {
            x(this).arrangeItems()
        })
    }

    function k(N) {
        console.log("Misc: initContentslider()");
        x(".contentslider").each(function() {
            x(this).contentslider({
                paging: true
            })
        });
        if (N.length > 0) {
            N.contentslider({
                autoplay: N.data("cs-autoplay"),
                cycle: N.data("cs-cycle"),
                duration: N.data("cs-duration"),
                delay: N.data("cs-delay"),
                type: "main-article-teaser",
                paging: true,
                changeLinks: false,
                endatfirst: N.data("cs-endatfirst")
            })
        }
    }

    function f(N) {
        console.log("Misc: initTooltips()");
        var O = [],
            P = {
                vertical: {
                    my: "center top+10",
                    at: "center bottom"
                },
                horizontal: {
                    my: "left+12 center",
                    at: "right center"
                }
            };
        N.find("[data-tooltip]").on("click", function(Q) {
            Q.preventDefault()
        });
        x.each(N.find("[data-original-title]"), function() {
            var Q = x(this),
                R = false;
            if (Modernizr.touch) {
                Q.on("click", function(S) {
                    S.stopPropagation();
                    if (R || typeof R == "undefined") {
                        Q.trigger("mouseout");
                        R = false
                    } else {
                        Q.trigger("mouseover");
                        R = true
                    }
                })
            }
            Q.tooltip({
                items: "[data-original-title]",
                content: function() {
                    return x(this).data("original-title")
                },
                show: null,
                hide: null,
                position: {
                    my: "center bottom-10",
                    at: "center top",
                    using: function(S, T) {
                        x(this).css(S);
                        x("<div>").addClass("arrow").addClass(T.vertical).addClass(T.horizontal).appendTo(this)
                    }
                }
            })
        });
        x.each(N.find('[data-tooltip="click"]'), function() {
            var Q = x(this),
                R = Q.data("tooltip-direction") || "vertical",
                S = false;
            O.push(Q);
            Q.tooltipX({
                items: Q,
                content: function() {
                    return x(x(this).attr("href")).html() + '<a href="#" class="action-icon action-icon--close"></a>'
                },
                show: null,
                hide: null,
                close: function() {
                    S = false
                },
                autoHide: false,
                position: {
                    my: P[R].my,
                    at: P[R].at,
                    using: function(T, U) {
                        x(this).css(T);
                        x("<div>").addClass("arrow").addClass(U.vertical).addClass(U.horizontal).appendTo(this)
                    }
                }
            }).on("click", function(T) {
                T.stopPropagation();
                T.preventDefault();
                if (S) {
                    Q.tooltipX("close");
                    S = false
                } else {
                    x.each(O, function() {
                        x(this).tooltipX("close")
                    });
                    Q.tooltipX("open");
                    S = true
                }
                setTimeout(function() {
                    var U = x("#" + Q.attr("aria-describedby"));
                    U.find(".action-icon--close").on("click", function(V) {
                        V.preventDefault();
                        Q.tooltipX("close");
                        S = false
                    })
                }, 500)
            }).off("mouseover")
        });
        x.each(N.find('[data-tooltip="mouseover"]'), function() {
            var Q = x(this),
                R = Q.data("tooltip-direction") || "vertical";
            Q.tooltip({
                items: Q,
                content: function() {
                    return x(x(this).attr("href")).html()
                },
                show: null,
                hide: null,
                position: {
                    my: P[R].my,
                    at: P[R].at,
                    using: function(S, T) {
                        x(this).css(S);
                        x("<div>").addClass("arrow").addClass(T.vertical).addClass(T.horizontal).appendTo(this)
                    }
                }
            })
        });
        x(".share-button").on("click", function() {
            x(this).blur()
        })
    }

    function o(N) {
        console.log("Misc: addToggleFlyoutListener()");
        N.on("click", function(P) {
            var O = x(this);
            if (O.hasClass("nav-button")) {
                P.preventDefault()
            }
            L(x(this))
        });
        x(".supports-no-touch .flyout-parent:not(.main-nav__item)").each(function() {
            var P = x(this),
                O;
            P.on("mouseenter", function() {
                O = setTimeout(function() {
                    P.addClass("flyout--hover")
                }, 200)
            }).on("mouseleave", function() {
                clearTimeout(O);
                P.removeClass("flyout--hover")
            })
        })
    }

    function s(N) {
        console.log("Misc: addOpenLinkInParentListener()");
        N.on("click", function(O) {
            O.preventDefault();
            I(window, x(this))
        })
    }

    function n(N) {
        console.log("Misc: addPrintPageListener()");
        x.each(N, function() {
            var O = x(this);
            if (O.data("print-init") == true) {
                J()
            } else {
                O.on("click", function(P) {
                    P.preventDefault();
                    J()
                })
            }
        })
    }

    function i(N) {
        console.log("Misc: addGridProductItemListener()");
        N.find(".article-item__info").hover(function(O) {
            m(x(this), O.type)
        })
    }

    function A(N) {
        console.log("Misc: addToggleFormSectionLinksListener()");
        N.find(".js__toggleFormSection-link").on("click", function(O) {
            O.preventDefault();
            p(x(this))
        })
    }

    function w(N) {
        console.log("Misc: addChangeSearchQueryListener()");
        N.find(".js__changeSearchQuery-link").on("click", function(O) {
            O.preventDefault();
            var P = N.find('input[type="text"]');
            shared.Forms.focusInput(P);
            shared.Forms.selectInput(P)
        })
    }

    function l(N) {
        console.log("Misc: addClosePopupListener()");
        N.on("click", function(Q) {
            Q.preventDefault();
            Q.stopPropagation();
            var P = x(".overlay-container.active").length,
                O = P === 1 ? false : true;
            b(x(this).closest(".popup"), O);
            x(this).closest(".supports-no-touch .flyout-parent:not(.main-nav__item)").trigger("mouseleave")
        })
    }

    function e(N) {
        console.log("Misc: addCloseWindowListener()");
        N.on("click", function(O) {
            O.preventDefault();
            t()
        })
    }

    function C(N) {
        console.log("Misc: addOpenPopupListener()");
        N.on("click", function(O) {
            O.preventDefault();
            r(x(O.currentTarget))
        })
    }

    function y(N) {
        console.log("Misc: addSetLinkViaSelectListener()");
        N.on("change", function() {
            q(x(this))
        })
    }

    function m(O, P) {
        console.log("Misc: toggleProductItemView()");
        var N = O.closest(".article-item");
        if (P === "mouseenter") {
            N.addClass("hover")
        } else {
            if (P === "mouseleave") {
                N.removeClass("hover")
            }
        }
    }

    function F(N) {
        console.log("Misc: addTabSystemListener()");
        N.on("click", function(R) {
            R.preventDefault();
            var P = x(this),
                O = x(P.attr("href"));
            shared.Misc.changeTab(O);
            if (P.parents(".mediacenter").length > 0) {
                var Q = O.find(".contentslider__area").index(O.find(".contentslider__area .active").parent());
                O.find(".paging li:eq(" + Q + ") a").trigger("click")
            }
        })
    }

    // open overlay listener
    function a(N) {
        console.log("Misc: addOpenOverlayListener()");
        N.on("click", function(O) {
            O.preventDefault();
            g(x(this))
        })
    }

    function h(O, R) {
        console.log("Misc: createOverlay()");
        var P = louis.Pattern.returnHtml("overlay"),
            Q = louis.Pattern.returnHtml(O),
            N;
        Q = shared.Misc.replacePlaceholderInString(Q, R);
        P = shared.Misc.replacePlaceholderInString(P, [Q]);
        N = x(P);
        D(N);
        K(N)
    }

    function z(N, P) {
        console.log("Misc: startAjaxRequest()");
        var O;
        N.addClass("xhr-loading");
        if (P == "click") {
            N.on("click.loading", function() {
                Q.abort();
                N.removeClass("xhr-loading").off("click.loading")
            })
        }
        if (N.attr("href")) {
            O = N.attr("href")
        } else {
            var R = N.is(":checked") ? 1 : 0;
            O = N.data("url") + "?value=" + R
        }
        var Q = x.ajax({
            url: O,
            success: function(U, S, W) {
                var T = W.getResponseHeader("content-type") || "",
                    V = U;
                if (T.indexOf("html") > -1) {
                    V = JSON.parse(V)
                }
                d(V)
            },
            error: function() {
                louis.Misc.createOverlay("systemMessage", ["caution", "attention", local.standardErrorMessage])
            },
            complete: function() {
                N.removeClass("xhr-loading").off("click.loading");
                runningXhr = shared.Helper.removeItemFromArray(runningXhr, Q)
            }
        });
        runningXhr.push(Q)
    }

    function d(N) {
        console.log("Misc: handleJsonResponse()");
        if (N.modifyHtmlElement) {
            shared.Misc.modifyHtmlElement(N.modifyHtmlElement)
        }
        if (N.html && N.newOverlay) {
            u(N.html)
        }
        if (typeof N.pageReload !== "undefined") {
            if (N.pageReload == true) {
                shared.Misc.reloadPageWithParam()
            }
        }
    }

    function u(N) {
        console.log("Misc: createNewOverlay()");
        var O = x(N);
        D(O);
        K(O);
        louis.Forms.init(O);
        if (typeof louis.ArticleDetail != "undefined") {
            louis.ArticleDetail.init(O)
        }
        if (typeof shared.Checkout != "undefined") {
            shared.Checkout.init(O)
        }
    }

    function M() {
        console.log("Misc: addTrackingPixel()")
    }

    function j(N) {
        console.log("Misc: setHeightOfCompareTabInPopup()");
        N.find(".tab-system").css("width", N.find(".table-data").outerWidth() + N.find(".info").outerWidth() + 60)
    }

    function v(N) {
        console.log("Misc: figcaptionWidthFix()");
        x.each(N, function() {
            var R = x(this),
                O = R.closest("figure").find("img"),
                Q = [],
                P;
            x.each(O, function() {
                Q.push(x(this).width())
            });
            P = Math.max.apply(null, Q);
            R.css("width", P)
        })
    }

    function p(N) {
        console.log("Misc: toggleFormSection()");
        var O = N.closest(".js__toggleFormSection"),
            Q = O.find(".js__toggleFormSection-toggle"),
            P = 0;
        O.addClass("sliding");
        Q.slideToggle(400, function() {
            P++;
            if (O.hasClass("closed")) {
                N.html(local.checkoutCloseFormClose + "<span></span>")
            } else {
                N.html(local.checkoutCloseFormEdit + "<span></span>")
            }
            if (P > 1) {
                return
            }
            setTimeout(function() {
                O.toggleClass("closed").removeClass("sliding")
            }, 100)
        })
    }

    function J() {
        console.log("Misc: printPage()");
        window.print()
    }

    function q(P) {
        console.log("Misc: setLinkViaSelect()");
        var Q = P.closest(".js__setLinkViaSelect").find(".button"),
            S = Q.attr("href"),
            N = S.indexOf("="),
            O = S.slice(0, N),
            R = P.val();
        Q.attr("href", O + "=" + R)
    }

    function r(O) {
        console.log("Misc: openPopup()");
        var P = O.data("popup-width") || 1000,
            N = O.data("popup-height") || 600,
            R = O.data("title") || "",
            Q = window.open(O.attr("href"), R, "width = " + P + ", height = " + N + ", resizable = yes, scrollbars = yes, menubar = no, toolbar = no, directories = no, location = no, status = no");
        Q.focus();
        $window.on("focus.hideTooltip", function() {
            setTimeout(function() {
                x(".share-button:focus").blur();
                $window.off("focus.hideTooltip")
            }, 1)
        })
    }

    function I(O, N) {
        console.log("Misc: openLinkInParent()");
        $window.blur();
        opener.location.href = N.attr("href");
        setTimeout(function() {
            opener.focus()
        }, 1)
    }

    // open overlay maker
    function g(P) {
        console.log("Misc: openOverlay()");
        var O = P.data("jump-to");
        $body.addClass("overlay-active");
        if (typeof P.data("keep-overlay") === "undefined" && P.closest(".overlay-container.active").length > 0) {
            b(P.closest(".overlay-container.active"), true)
        }
        if (P.data("ajax")) {
            $overlayBg.addClass("active");
            H(P, O)
        } else {
            var N = x(P.attr("href"));
            G(N, O)
        }
        if (x("[data-tooltip][aria-describedby]").length > 0) {
            x("[data-tooltip][aria-describedby]").tooltipX("close")
        }
        $window.on("keydown.navigation", function(Q) {
            if (Q.keyCode === 27) {
                Q.preventDefault();
                x(".overlay-container.active").find(".action-icon--close").trigger("click");
                x("html,body").removeAttr("style")
            }
        })
    }

    function G(Q, P) {
        console.log("Misc: positionOverlay()");
        var N = Q.find("> .overlay");
        Q.addClass("active");
        $body.addClass("overlay-active");
        N.removeAttr("style").removeClass("smallerThanViewport");
        var S = $window.scrollTop(),
            O = $window.height(),
            R = N.outerHeight();
        $overlayBg.addClass("active");
        if (Q.data("dontcloseviabg") == false) {
            Q.on("click.close", function() {
                b(Q)
            });
            N.on("click", function(T) {
                T.stopPropagation()
            })
        }
        if (R < O - 40) {
            N.css("margin-top", R / 2 * -1).addClass("smallerThanViewport")
        } else {
            Q.scrollTop(0)
        }
        shared.Misc.setFocus(Q);
        if (P) {
            E(x(P))
        }
        Q.trigger("inview")
    }

    function H(P, O) {
        console.log("Misc: loadOverlayViaXhr()");
        var N, R, Q = false;
        $overlayBg.addClass("overlay-content-loading");
        $overlayBg.on("click.cancel", function() {
            Q = true;
            B(R)
        });
        R = x.ajax({
            url: P.data("url"),
            success: function(U, S, V) {
                var T = V.getResponseHeader("content-type") || "";
                if (T.indexOf("json") > -1) {
                    N = x(U.html)
                } else {
                    N = x(U)
                }
                if (U.modifyHtmlElement) {
                    shared.Misc.modifyHtmlElement(U.modifyHtmlElement)
                }
                D(N, O);
                K(N);
                shared.Misc.init(N);
                shared.Forms.init(N);
                louis.Forms.init(N);
                if (typeof louis.ArticleDetail != "undefined") {
                    louis.ArticleDetail.init(N)
                }
                if (typeof shared.Checkout != "undefined") {
                    shared.Checkout.init(N)
                }
                $overlayBg.off("click.cancel")
            },
            error: function() {
                if (!Q) {
                    h("systemMessage", ["caution", "attention", local.standardErrorMessage])
                }
                $overlayBg.off("click.cancel")
            }
        })
    }

    function B(N) {
        console.log("Misc: cancelOverlayViaXhr()");
        N.abort();
        $overlayBg.removeClass("overlay-content-loading active");
        x(".overlay-container.active").remove()
    }

    function D(N, O) {
        console.log("Misc: appendLoadedContent()");
        if ($body.hasClass("popup-window")) {
            $body.append(N)
        } else {
            if (x(".checkout").length > 0) {
                $overlayBg.before(N)
            } else {
                if (x(".main-ending:eq(0)").length > 0) {
                    x(".main-ending:eq(0)").before(N)
                } else {
                    if ($overlayBg.length > 0) {
                        $overlayBg.before(N)
                    } else {
                        $body.append(N)
                    }
                }
            }
        }
        G(N, O);
        $overlayBg.removeClass("overlay-content-loading")
    }

    function E(P, R) {
        console.log("Misc: jumpToContent()");
        var N = P.parents(".js__tab-system"),
            U = P.closest(".overlay"),
            T = P.closest(".overlay-container"),
            O = U.length > 0 ? true : false,
            V, S, Q;
        if (N.length > 0 && !N.find(".tab.active").is(P)) {
            shared.Misc.changeTab(P)
        }
        if (O) {
            V = T;
            S = P.offset().top - T.scrollTop() - $window.scrollTop()
        } else {
            V = x("html, body");
            S = P.offset().top - 10
        }
        if (R && P.length > 0) {
            Q = 750
        } else {
            Q = 0
        }
        V.animate({
            scrollTop: S
        }, Q)
    }

    function t() {
        console.log("Misc: closeWindow()");
        self.close()
    }

    function b(O, N) {
        console.log("Misc: closePopup()");
        O.removeClass("active");
        if (O.hasClass("overlay-container") && !N) {
            $overlayBg.removeClass("active disabled");
            O.off("click.close");
            $window.off("keydown.navigation");
            $body.removeClass("overlay-active");
            if (O.find(".video-js").length > 0) {
                louis.MediaCenter.Overlay.pauseVideo()
            }
        }
        if (O.parents(".flyout-parent").length > 0) {
            O.parents(".flyout--active").removeClass("flyout--active flyout--hover");
            timeout = setTimeout(function() {
                O.removeAttr("style")
            }, 100)
        } else {
            if (O.hasClass("info-box")) {
                O.removeClass("active");
                timeout = setTimeout(function() {
                    O.removeAttr("style")
                }, 100)
            }
        }
        shared.Misc.keepOrRemoveClosedAppendedContent(O);
        if (runningXhr.length > 0) {
            shared.Misc.cancelRunningXhrs()
        }
        x.event.trigger({
            type: "closePopup"
        })
    }

    function L(O) {
        console.log("Misc: toggleFlyout()");
        var N = O.closest(".flyout-parent");
        if (!N.hasClass("flyout--active")) {
            O.off("click.openFlyout");
            x(".flyout--active").removeClass("flyout--active");
            N.addClass("flyout--active");
            $document.on("click.closePopup", function(P) {
                if (x(P.target).parents(".flyout--active").length == 0) {
                    L(O);
                    N.find(".action-icon--close").trigger("click");
                    $document.off("click.closePopup")
                }
            })
        }
    }
    return {
        init: K,
        closePopup: b,
        jumpToContent: E,
        addTrackingPixel: M,
        openOverlay: g,
        appendLoadedContent: D,
        positionOverlay: G,
        createOverlay: h,
        createNewOverlay: u,
        startAjaxRequest: z
    }
}(jQuery));
louis.Background = (function(f) {
    var m = true,
        a, i, d, g, b, j = false;

    function o(p) {
        a = p.find("img");
        i = h();
        d = n();
        if (a.length > 0 && a[0].width > 100 && a[0].height > 100) {
            p.css("height", i);
            c(p);
            $document.load(function() {
                c(p)
            });
            k(p)
        }
    }

    function k(p) {
        console.log("Background: addSetBackgroundPositionListener()");
        if (MutationObserver && requestAnimFrame) {
            $window.on("resize", function() {
                i = h();
                d = n();
                p.css("height", i);
                c(p)
            }).on("scroll", function() {
                e(p)
            });
            l(p)
        } else {
            setInterval(function() {
                i = h();
                d = n();
                c(p)
            }, 1000 / 60)
        }
    }

    function e(p) {
        if (!j) {
            requestAnimFrame(function() {
                c(p)
            });
            j = true
        }
    }

    function l(q) {
        var p = new MutationObserver(function(r, s) {
            i = h();
            d = n();
            c(q)
        });
        p.observe(document.querySelector(".main"), {
            subtree: true,
            attributes: true
        })
    }

    function h() {
        return a.height()
    }

    function n() {
        return $footer.offset().top
    }

    function c(q) {
        var s = $body.height(),
            r = $footer.outerHeight() ? $footer.outerHeight() : 0,
            p = s - r - i + 1;
        if (d - $window.scrollTop() < i) {
            if (d != g || m) {
                m = false;
                if (Modernizr.csstransforms) {
                    q.css({
                        position: "absolute",
                        "-webkit-transform": "translateY(" + p + "px)",
                        "-moz-transform": "translateY(" + p + "px)",
                        "-ms-transform": "translateY(" + p + "px)",
                        "-o-transform": "translateY(" + p + "px)",
                        transform: "translateY(" + p + "px)"
                    })
                } else {
                    q.css({
                        position: "absolute",
                        top: p
                    })
                }
            }
        } else {
            if (q.attr("style")) {
                if (Modernizr.csstransforms) {
                    q.css({
                        position: "fixed",
                        "-webkit-transform": "translateY(0px)",
                        "-moz-transform": "translateY(0px)",
                        "-ms-transform": "translateY(0px)",
                        "-o-transform": "translateY(0px)",
                        transform: "translateY(0px)"
                    })
                } else {
                    q.css({
                        position: "fixed",
                        top: 0
                    })
                }
            }
            m = true
        }
        g = d;
        b = i;
        j = false
    }
    return {
        init: o
    }
}(jQuery));
louis.Forms.Additional = (function(d) {
    var x, i, a = [];

    function q(J) {
        var E = d(".helmet-advisor"),
            C = E.find("form"),
            D = E.find(".street-type"),
            G = D.find("input"),
            F = D.find(".result__total"),
            B = D.find(".result__todo"),
            A = J.find(".js__currencyCalculator");
        if (A.length > 0) {
            l(A)
        }
        if (G.length > 0) {
            g(C, G, F, B, true);
            m(C, G, F, B)
        }
        if (J.find(".js__chooseAnswerType").length > 0) {
            var I = J.find(".js__chooseAnswerType").closest("form"),
                H = {
                    form: I,
                    answerType: I.find(".callback-by"),
                    chooseAnswerType: I.find('input[name="answer_type"]'),
                    choosePeriod: I.find(".choose-period"),
                    selects: {
                        all: I.find(".choose-period select"),
                        day: I.find('select[name="callback_time[day]"]'),
                        from: {
                            hour: I.find('select[name="callback_time[from_hour]"]'),
                            minute: I.find('select[name="callback_time[from_minute]"]')
                        },
                        to: {
                            hour: I.find('select[name="callback_time[to_hour]"]'),
                            minute: I.find('select[name="callback_time[to_minute]"]')
                        }
                    },
                    submit: I.find('[type="submit"]')
                };
            x = parseInt(I.data("minperiod"), 10);
            i = parseInt(I.data("todayplushours"), 10);
            e(H);
            c(H);
            t(H);
            v(H)
        }
    }

    function l(A) {
        console.log("Forms.Additional: addConvertPriceListener()");
        var B = true;
        A.find(".button").on("click", function(D) {
            D.preventDefault();
            (function C() {
                setTimeout(function() {
                    if (A.data("validation-done")) {
                        if (!A.data("invalid")) {
                            h(A, B);
                            B = false
                        }
                    } else {
                        C()
                    }
                }, 10)
            }())
        })
    }

    function m(A, C, B, D) {
        console.log("Forms.Additional: addStreetTypeTotalListener()");
        C.on("change keyup", function() {
            g(A, C, B, D, true)
        });
        A.find('[type="submit"]').on("click", function() {
            g(A, C, B, D, false)
        })
    }

    function t(A) {
        console.log("Forms.Additional: addCallbackByListener()");
        A.chooseAnswerType.on("change", function() {
            r(d(this), A)
        })
    }

    function e(A) {
        console.log("Forms.Additional: addChoosePeriodListener()");
        A.selects["day"].on("change.changeDay", function() {
            var C = d(this);
            if (C.find("option:selected").data("today") == true) {
                currentTime = new Date();
                var B = y(currentTime);
                w(B, A)
            } else {
                n(A.selects);
                j(A.selects["from"]);
                if (u(A.selects)) {
                    k(A)
                }
            }
        });
        d.each(A.selects["from"], function() {
            this.on("change.changeBegin", function() {
                currentTime = new Date();
                if (u(A.selects)) {
                    k(A)
                }
            })
        })
    }

    function c(A) {
        console.log("Forms.Additional: addValidateChoosePeriodListener()");
        A.submit.on("click", function(C) {
            C.preventDefault();
            if (A.form.hasClass("js__formValidation")) {
                (function B() {
                    if (A.form.data("validation-done")) {
                        if (shared.Forms.Validation.checkIfValidationIsRequired(A.selects["day"])) {
                            o(A)
                        } else {
                            A.form.data("additional-invalid", false)
                        }
                    } else {
                        B()
                    }
                }())
            } else {
                o(A)
            }
        })
    }

    function h(P, E) {
        console.log("Forms.Additional: convertPrice()");
        if (!E) {
            b(a)
        }
        var C = d("#currency-calculator__from-to"),
            A = C.find("option:selected"),
            I = d("#currency-calculator__from"),
            G = d("#label-currency-calculator__from"),
            H = d("#currency-calculator__to"),
            B = d("#label-currency-calculator__to"),
            D = P.data("separator"),
            F = parseFloat(A.val()),
            M = A.data("from"),
            L = A.data("to"),
            O, K = I.val().trim();
        K = K.replace(D, ".");
        (function N() {
            var Q = K.match(/\.|,/g);
            if (Q !== null && Q.length > 1) {
                K = K.replace(/\.|,/, "");
                N()
            }
        }());
        var J = parseFloat(K).toFixed(2).toString().replace(/\.|,/, D);
        I.val(J);
        O = parseFloat(K) * F;
        O = O.toFixed(2);
        O = O.toString().replace(".", D);
        H.val(O);
        G.html(M);
        B.html(L + "*");
        a.amount = P.data("amount");
        a.value = J;
        a.from = M;
        a.converted = O;
        a.to = L
    }

    function b(A) {
        console.log("Forms.Additional: addConversionToList()");
        var D = "<li><span>" + A.value + " " + A.from + "</span> <span>тЙИ " + A.converted + " " + A.to + "</span></li>",
            C = d(".currency-calculator__previous-conversions__list"),
            B = C.find("ul");
        if (B.find(".noPreviousConversions").length > 0) {
            B.html(D)
        } else {
            if (B.find("li").length == A.amount) {
                B.find("li:eq(0)").remove()
            }
            B.append(D)
        }
        C.removeClass("hidden");
        A = []
    }

    function g(A, D, B, F, G) {
        console.log("Forms.Additional: calcTotal()");
        if (A.find(".input-container .error").length > 0) {
            return
        }
        var E = 0;
        D.each(function() {
            var H = parseInt(d(this).val(), 10);
            if (isNaN(H)) {
                H = 0
            }
            E += H
        });
        if (isNaN(E)) {
            E = 0
        }
        B.html(E);
        F.html(100 - E);
        if (E > 100) {
            A.data("additional-invalid", true);
            B.add(F).addClass("attention").removeClass("important-positive");
            if (!G) {
                var C = JSON.parse('{ "' + D.filter(":eq(0)").attr("name") + '": { "helmetAdvisorNot100percent": "' + local.helmetAdvisorNot100percent + '" } }');
                shared.Forms.Validation.addErrors(A, C)
            }
        } else {
            A.data("additional-invalid", false);
            if (E == 100) {
                B.add(F).addClass("important-positive").removeClass("attention")
            } else {
                B.add(F).removeClass("attention important-positive")
            }
            shared.Forms.Validation.removeErrors(D, D.filter(":eq(0)").closest(".input-container-group"), "helmetAdvisorNot100percent")
        }
        A.data("additional-validation-done", true)
    }

    function r(A, B) {
        console.log("Forms.Additional: callbackBy()");
        if (A.val() === "phone") {
            B.form.data("additional-validation-done", false);
            v(B)
        } else {
            B.form.data("additional-invalid", false).data("additional-validation-done", true);
            B.answerType.find(".input-error").removeClass("input-error").end().find(".error").remove()
        }
    }

    function o(B) {
        console.log("Forms.Additional: validateChoosePeriod()");
        var A;
        if (f(B.selects) < x) {
            if (x == 60) {
                A = local.callbackMinOneHour
            } else {
                A = shared.Misc.replacePlaceholderInString(local.callbackMin, [x])
            }
            if (B.choosePeriod.find(".error").length === 0) {
                B.choosePeriod.append('<ul class="error">' + A + ".</ul>")
            }
            B.selects["all"].on("change.revalidate", function() {
                o(B)
            });
            B.selects["all"].each(function() {
                var C = d(this);
                if (C.attr("name") !== "answer_day") {
                    C.addClass("input-error")
                }
            });
            B.form.data("additional-invalid", true)
        } else {
            B.choosePeriod.find(".error").remove();
            B.selects["all"].removeClass("input-error");
            B.form.data("additional-invalid", false)
        }
        B.form.data("additional-validation-done", true)
    }

    function v(B) {
        console.log("Forms.Additional: initChoosePeriod()");
        currentTime = new Date();
        B.selects["day"].find("option:first").prop("selected", true);
        if (B.selects["day"].find("option:selected").data("today") === true) {
            var A = y(currentTime);
            w(A, B)
        } else {
            j(B.selects["from"]);
            if (u(B.selects)) {
                k(B)
            }
        }
    }

    function n(A) {
        console.log("Forms.Additional: enableAllOptions()");
        A.all.find("option").prop("disabled", false)
    }

    function j(A) {
        console.log("Forms.Additional: setEarliestPossiblePeriodBegin()");
        A.hour.find("option:not(:disabled):eq(0)").prop("selected", true);
        A.minute.find("option:eq(0)").prop("selected", true)
    }

    function f(C) {
        console.log("Forms.Additional: getDifferenceBetweenStartAndEnd()");
        var B = parseInt(C.from["hour"].val(), 10) * 60,
            H = parseInt(C.from["minute"].val(), 10),
            A = parseInt(C.to["hour"].val(), 10) * 60,
            G = parseInt(C.to["minute"].val(), 10),
            F = B + H,
            E = A + G,
            D = E - F;
        return D
    }

    function p(A, B) {
        console.log("Forms.Additional: setPeriodBeginHour()");
        B.selects["from"]["hour"].find('option[value="' + A + '"]').prop("selected", true)
    }

    function u(A) {
        console.log("Forms.Additional: checkIfChosenPeriodIsTooShort()");
        if (f(A) < x) {
            return true
        }
    }

    function z(B) {
        console.log("Forms.Additional: setPeriodBeginMinute()");
        var A = s();
        B.selects["from"]["minute"].find('option[value="' + A + '"]').prop("selected", true)
    }

    function k(F) {
        console.log("Forms.Additional: setPeriodEndRelatedToPeriodBegin()");
        var B = parseInt(F.selects["from"]["hour"].prop("value"), 10),
            D = parseInt(F.selects["from"]["minute"].prop("value"), 10),
            A = Math.floor(x / 60),
            C = D + (x % 60),
            E;
        if (C > 59) {
            A++;
            C %= 60
        }
        if (C === 0) {
            C = "00"
        }
        toHour = B + A;
        E = F.selects["to"]["hour"].find('option[value="' + toHour + '"]');
        if (E.length > 0) {
            E.prop("selected", true);
            F.selects["to"]["minute"].find('option[value="' + C + '"]').prop("selected", true);
            F.choosePeriod.find(".error").remove().end().find(".input-error").removeClass("input-error")
        } else {
            o(F)
        }
    }

    function s() {
        console.log("Forms.Additional: getNextQuarter()");
        var B = parseInt(currentTime.getMinutes(), 10),
            A;
        if (B > 45) {
            A = 0
        } else {
            if (B > 30) {
                A = 45
            } else {
                if (B > 15) {
                    A = 30
                } else {
                    A = 15
                }
            }
        }
        return A
    }

    function y(B) {
        console.log("Forms.Additional: getMinimumHour()");
        var D = B.getHours(),
            C = B.getMinutes(),
            A;
        A = D + i;
        if (C > 45) {
            A++
        }
        return A
    }

    function w(A, B) {
        console.log("Forms.Additional: disableHours()");
        d.each(B.selects["from"]["hour"].find("option"), function() {
            var C = d(this);
            if (parseInt(C.val(), 10) < A) {
                C.prop("disabled", true)
            }
        });
        d.each(B.selects["to"]["hour"].find("option"), function() {
            var C = d(this);
            if (parseInt(C.val(), 10) <= A) {
                C.prop("disabled", true)
            }
        });
        p(A, B);
        z(B);
        k(B)
    }
    return {
        init: q
    }
}(jQuery));
louis.RequestData = (function() {
    function a(b, c) {
        console.log("RequestData: sortData()");

        function d(e) {
            return function(g, f) {
                var i = g[e],
                    h = f[e];
                if (e == "capacity" || e == "distance") {
                    i = parseFloat(i);
                    h = parseFloat(h)
                }
                if (i > h) {
                    return 1
                }
                if (i < h) {
                    return -1
                }
                return 0
            }
        }
        return b.sort(d(c))
    }
    return {
        sortData: a
    }
}());
louis.RequestData.Header = (function(a) {
    function c(e) {
        var g = e.find('select[data-type="data"]'),
            i = e.find('select[name*="bikes"]'),
            j = i.find("option:first"),
            h = e.find(".bike-selection-sortby"),
            d = e.data("select-from-list-url"),
            f = a("#mybike-flyout-list");
        shared.RequestData.addSelectListener(e, g, i, j, d);
        shared.RequestData.addSortListener(h, i, j);
        if (f.length > 0) {
            b(f, g)
        }
    }

    function b(e, d) {
        console.log("RequestData.Header: addAddBikeLinkListener()");
        e.on("click", ".add-bike", function() {
            d.first().find("option:eq(0)").prop("selected", true).end().trigger("change")
        })
    }
    return {
        init: c
    }
}(jQuery));
if (!window.console) {
    console = {
        log: function() {}
    }
}
if (typeof String.prototype.trim !== "function") {
    String.prototype.trim = function() {
        return this.replace(/^\s+|\s+$/g, "")
    }
}
window.requestAnimFrame = (function() {
    return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame || window.oRequestAnimationFrame
}());
MutationObserver = window.MutationObserver || window.WebKitMutationObserver;
(function(a) {
    a.widget("custom.tooltipX", a.ui.tooltip, {
        options: {
            autoShow: true,
            autoHide: true
        },
        _create: function() {
            this._super();
            if (!this.options.autoShow) {
                this._off(this.element, "mouseover focusin")
            }
        },
        _open: function(c, d, b) {
            this._superApply(arguments);
            if (!this.options.autoHide) {
                this._off(d, "mouseleave focusout")
            }
        }
    })
}(jQuery));
louis.Pattern = (function() {
    var b = {
        overlay: '<div data-mustrevalidate="true" id="js-overlay" class="overlay-container popup"><div class="overlay"><a href="#" class="action-icon action-icon--close">Schlie├Яen</a>%REPLACE%</div></div>',
        storesListItem: '<tr class="divider"><td colspan="2" class="store-name"><span class="store-title">%REPLACE%</span></td><td colspan="2" class="store-attributes"><ul class="attributes">%REPLACE%</ul></td></tr><tr itemscope itemtype="http://schema.org/LocalBusiness"><td class="store-image" itemscope itemtype="http://schema.org/ImageObject"><a href="%REPLACE%"><img width="155" height="155" src="%REPLACE%" alt="%REPLACE%" itemprop="contentUrl"></a></td><td class="store-address" itemprop="address" itemscope itemtype="http://schema.org/PostalAddress"><p><address><span itemprop="streetAddress">%REPLACE%</span><br>%REPLACE% <span itemprop="addressLocality">%REPLACE%</span><br></p></address><br><span itemprop="telephone">%REPLACE%</span><br><br><p>%REPLACE%<br></p><a class="button button--link gotoStoreButton" href="%REPLACE%">%REPLACE%</a></td><td style="text-align: right;padding-right: 25px; width: 100px;">%REPLACE%</td><td class="store-opening-times"><dl class="opening-times-list">%REPLACE%</dl>%REPLACE%</td></tr>',
        contentsliderChangeLinks: '<ul class="change control"><li class="prev"><a href="#previous"><span>previous</span></a></li><li class="next"><a href="#next"><span>next</span></a></li></ul>',
        backgroundImage: '<div id="js__bg" class="bg"><img alt="Louis Background" src="%REPLACE%"></div>'
    };

    function a(c) {
        return b[c]
    }
    return {
        returnHtml: a
    }
}());
(function(a) {
    a.fn.arrangeItems = function() {
        return this.each(function() {
            var b = a(this),
                f, e = b.find(".js__arrangeItems-item.odd"),
                d = b.find(".js__arrangeItems-item.even");
            if (e.length === 0) {
                b.find("> :eq(0)").addClass("odd")
            }
            if (d.length === 0) {
                b.find("> :eq(1)").addClass("even")
            }
            f = b.find(".js__arrangeItems-item:not(.odd,.even)");
            a.each(f, function() {
                var g = a(this);
                c(b, g)
            });

            function c(j, n) {
                var m = j.find(".odd").last(),
                    p = j.find(".even").last(),
                    q = m.outerHeight(),
                    o = m.offset().top,
                    g = q + o,
                    i = p.outerHeight(),
                    h = p.offset().top,
                    l = i + h,
                    k;
                if (l < g) {
                    k = "even"
                } else {
                    k = "odd"
                }
                n.addClass(k)
            }
        })
    }
}(jQuery));
louis.AutoSuggest = (function(d) {
    function h(k) {
        k.find(".result__link").on("mouseover.selection", function() {
            var l = d(this);
            k.find(".header-search__result.selected").removeClass("selected");
            l.closest(".header-search__result").addClass("selected")
        })
    }

    function b(k) {
        var l = k.find(".header-search__result"),
            m = l.length;
        $window.on("keydown.autosuggest", function(p) {
            if (p.keyCode === 38 || p.keyCode === 40) {
                p.preventDefault();
                var o = l.filter(".selected"),
                    n = e(p.keyCode, l, m, o);
                i(o);
                if (n) {
                    c(n)
                }
            } else {
                if (p.keyCode === 27) {
                    p.preventDefault();
                    shared.AutoSuggest.removeResults();
                    g()
                }
            }
        });
        $document.on("click.removeResultList", function(n) {
            if (d(n.target).closest(".header-search-container").length == 0) {
                shared.AutoSuggest.removeResults();
                g()
            }
        })
    }

    function g() {
        $window.off("keydown.autosuggest");
        $document.off("click.removeResultList")
    }

    function f(k) {
        k.find(".header-search__result").off("mouseover.selection")
    }

    function a(l, k) {
        d.ajax({
            url: k + "?lang=" + lang + "&pattern=" + encodeURIComponent(l),
            success: function(m) {
                shared.AutoSuggest.buildResultsList(m, l)
            },
            error: function() {},
            complete: function() {}
        })
    }

    function e(k, o, p, n) {
        var m = o.index(n),
            l;
        if (k === 38) {
            if (n.length == 0) {
                l = o.last()
            } else {
                if (m == 0) {
                    l = false;
                    i(n);
                    shared.Misc.setFocus(d("#header-search-q"))
                } else {
                    l = d(o.get(m - 1))
                }
            }
        } else {
            if (k === 40) {
                if (n.length == 0) {
                    l = o.first()
                } else {
                    if (m == p - 1) {
                        l = false;
                        i(n);
                        shared.Misc.setFocus(d("#header-search-q"))
                    } else {
                        l = d(o.get(m + 1))
                    }
                }
            }
        }
        return l
    }

    function j(n, l) {
        var k = d(".header-search__results");
        if (k.length > 0) {
            k.find("> ul").html(l)
        } else {
            var m = '<div class="header-search__results"><a href="#" class="action-icon action-icon--close">&times;</a><ul>' + l + "</ul></div>";
            n.append(m);
            n.find(".action-icon--close").on("click", function(o) {
                o.preventDefault();
                $document.trigger("click")
            });
            k = d(".header-search__results")
        }
        b(k);
        h(k);
        return k
    }

    function c(k) {
        k.addClass("selected");
        k.find(".result__link").focus()
    }

    function i(k) {
        k.removeClass("selected")
    }
    return {
        getResults: a,
        appendResults: j,
        removeKeyboardListener: g,
        removeMouseOverListener: f
    }
}(jQuery));
louis.HelmetAdvisor = (function(b) {
    function a(d) {
        try {
            var c = b("#" + d.data("filter-id"))[0]
        } catch (f) {
            return
        }
        d.on("click", function() {
            b(".helmet-advisor__filter").removeClass("active");
            b(c).addClass("active");
            if (b(c).hasClass("helmet-advisor--step2-overlay")) {
                b(".helmet-advisor__step").removeClass("active");
                b(".helmet-advisor__step--step2").addClass("active")
            }
            if (b(c).hasClass("helmet-advisor--step3-overlay")) {
                b(".helmet-advisor__step").removeClass("active");
                b(".helmet-advisor__step--step3").addClass("active")
            }
        })
    }
    return {
        init: function() {
            b(".helmet-advisor__show-filter").each(function() {
                if (!b(this).data("filter-id")) {
                    return
                }
                a(b(this))
            })
        }
    }
}(jQuery));
shared.ArticleDetail = (function(a) {
    a.changeMediaCenterImageAccordingToVariant = function() {
        console.log("shared.ArticleDetail: changeMediaCenterImageAccordingToVariant()");
        var e = $(".article__variant-availability");
        if (e.data("setmediacenterimage")) {
            var c = $(".mediacenter-preview .mediacenter-thumbs"),
                d = c.find('img[src$="' + e.data("setmediacenterimage") + '"]'),
                b;
            if (d.length == 0) {
                d = c.find('img[data-lazy-src*="' + e.data("setmediacenterimage") + '"]')
            }
            b = c.find(".contentslider__area").index(d.closest(".contentslider__area"));
            c.find(".paging li:eq(" + b + ") a").trigger("click");
            d.closest("a").trigger("click")
        }
    };
    a.testForInitialSelectedVariant = function() {
        console.log("shared.ArticleDetail: testForInitialSelectedVariant()");
        return $(".article__variant-availability").hasClass("active")
    };
    return a
}(shared.ArticleDetail || {}));
louis.ArticleDetail = (function(g) {
    var a, l, e, k, i, d, m, h, c;

    function n(o) {
        if (o.find(".article__order-container").length > 0) {
            a = o.find(".article__order-container");
            l = a.find("select");
            e = l.last();
            k = a.find("#article__order-qty");
            i = a.find(".article__variant");
            d = i.find(".article__variant-availability");
            m = o.find(".article__introduction");
            h = m.find(".article__description-excerpt");
            if (shared.ArticleDetail.testForInitialSelectedVariant()) {
                shared.Forms.changeFormValidationState(a.find(".article__variant-selection"), false);
                j()
            }
            b();
            shared.RequestData.ArticleDetail.init(a)
        }
    }

    function j() {
        console.log("ArticleDetail: reformatArticleVariant()");
        if (!d.hasClass("active")) {
            d.addClass("active")
        }
        var p = m.offset().top + m.outerHeight(),
            t = m.find(".additional-desc-link"),
            r = 20,
            s = g("#variants");
        if (k.val() == "") {
            k.val(1)
        }
        g.each(t, function() {
            r += g(this).outerHeight()
        });
        d = i.find(".article__variant-availability");
        if (p > d.offset().top * 2) {
            var o = d.offset().top * 2 - h.offset().top;
            h.css("height", o - r).addClass("truncated");
            if (m.find(".js__jumpToContent").length == 0) {
                h.after('<p class="additional-desc-link"><a class="truncate-link js__jumpToContent" href="#description">' + local.more + " тАж</a></p>");
                m.find(".js__jumpToContent").on("click", function(v) {
                    v.preventDefault();
                    var u = g(g(this).attr("href"));
                    louis.Misc.jumpToContent(u, true)
                })
            }
        }
        if (s.length > 0) {
            var q = g("#selected-article-no").text();
            s.find('tbody tr[data-articleno!="' + q + '"]').removeClass("print--true");
            s.find('tbody tr[data-articleno="' + q + '"]').addClass("print--true")
        }
    }

    function f() {
        console.log("ArticleDetail: restoreDefaultData()");
        h.removeClass("truncated").removeAttr("style");
        d.removeClass("active");
        d.closest("form").find("[data-validate]").data("validate", true);
        var o = g("#variants");
        if (o.length > 0) {
            o.find("tbody tr:not(.print--true)").addClass("print--true")
        }
        i.html(c);
        louis.Misc.init(i)
    }

    function b() {
        console.log("ArticleDetail: storeDefaultDataOfArticleGroup()");
        if (e.length > 0 && e.val() != "") {
            g.ajax({
                url: a.find("form").data("url") + "?get=default-html",
                success: function(q, o, s) {
                    var p = s.getResponseHeader("content-type") || "",
                        r = q;
                    if (p.indexOf("html") > -1) {
                        r = JSON.parse(r)
                    }
                    c = r.html
                }
            })
        } else {
            c = i.html()
        }
    }
    return {
        init: n,
        reformatArticleVariant: j,
        restoreDefaultData: f
    }
}(jQuery));
(function(c) {
    var l = {},
        b, m, e = document,
        j = window,
        i = e.documentElement,
        k = c.expando,
        a;
    c.event.special.inview = {
        add: function(d) {
            l[d.guid + "-" + this[k]] = {
                data: d,
                $element: c(this)
            };
            if (!a && !c.isEmptyObject(l)) {
                c(j).bind("scroll resize", function() {
                    b = m = null
                });
                if (!i.addEventListener && i.attachEvent) {
                    i.attachEvent("onfocusin", function() {
                        m = null
                    })
                }
                a = setInterval(g, 250)
            }
        },
        remove: function(d) {
            try {
                delete l[d.guid + "-" + this[k]]
            } catch (n) {}
            if (c.isEmptyObject(l)) {
                clearInterval(a);
                a = null
            }
        }
    };

    function h() {
        var o, d, n = {
            height: j.innerHeight,
            width: j.innerWidth
        };
        if (!n.height) {
            o = e.compatMode;
            if (o || !c.support.boxModel) {
                d = o === "CSS1Compat" ? i : e.body;
                n = {
                    height: d.clientHeight,
                    width: d.clientWidth
                }
            }
        }
        return n
    }

    function f() {
        return {
            top: j.pageYOffset || i.scrollTop || e.body.scrollTop,
            left: j.pageXOffset || i.scrollLeft || e.body.scrollLeft
        }
    }

    function g() {
        var p = c(),
            o, n = 0;
        c.each(l, function(z, y) {
            var w = y.data.selector,
                x = y.$element;
            p = p.add(w ? x.find(w) : x)
        });
        o = p.length;
        if (o) {
            b = b || h();
            m = m || f();
            for (; n < o; n++) {
                if (!c.contains(i, p[n])) {
                    continue
                }
                var u = c(p[n]),
                    v = {
                        height: u.height(),
                        width: u.width()
                    },
                    d = u.offset(),
                    q = u.data("inview"),
                    s, r, t;
                if (!m || !b) {
                    return
                }
                if (d.top + v.height > m.top && d.top < m.top + b.height && d.left + v.width > m.left && d.left < m.left + b.width) {
                    s = (m.left > d.left ? "right" : (m.left + b.width) < (d.left + v.width) ? "left" : "both");
                    r = (m.top > d.top ? "bottom" : (m.top + b.height) < (d.top + v.height) ? "top" : "both");
                    t = s + "-" + r;
                    if (!q || q !== t) {
                        u.data("inview", t).trigger("inview", [true, s, r])
                    }
                } else {
                    if (q) {
                        u.data("inview", false).trigger("inview", [false])
                    }
                }
            }
        }
    }
})(jQuery);
! function(B) {
    function A(e, d, f) {
        for (e = String(e); e.length < d;) {
            e = String(f) + e
        }
        return e
    }

    function z(e, d, f) {
        return e > f ? f : d > e ? d : e
    }

    function y(f, e, h, g) {
        for (; f > h;) {
            f -= g
        }
        for (; e > f;) {
            f += g
        }
        return f
    }

    function x(b) {
        return b.preventDefault(), !1
    }

    function w() {
        window.console && window.console.log && window.console.log.apply(window.console, arguments)
    }

    function v(e, d, f) {
        f && e.bind(d + "." + p, f)
    }

    function u(b) {
        b.unbind("." + p)
    }

    function t(i) {
        var h, n, m = "string" == typeof i.source ? [i.source] : i.source,
            l = 0,
            k = [],
            j = function() {
                l += 1, "function" == typeof i.progress && i.progress({
                    loaded: l,
                    total: m.length,
                    percent: Math.round(l / m.length * 100)
                }), l === k.length && "function" == typeof i.complete && i.complete(k)
            };
        for (h = 0; h < m.length; h += 1) {
            n = new Image, k.push(n), n.onload = n.onabort = n.onerror = j, n.src = m[h]
        }
    }

    function s(j, f) {
        var D, C, n = (f || j).width,
            m = (f || j).height;
        if (n * m > 1048576) {
            if (D = document.createElement("canvas"), !D || !D.getContext || !D.getContext("2d")) {
                return !1
            }
            D.width = D.height = 1, C = D.getContext("2d"), C.fillStyle = "FF00FF", C.fillRect(0, 0, 1, 1), C.drawImage(j, -n + 1, 0);
            try {
                var l = C.getImageData(0, 0, 1, 1).data;
                return 255 === l[0] && 0 === l[1] && 255 === l[2]
            } catch (k) {
                return w(k.message, k.stack), !1
            }
        }
        return !1
    }

    function r(d) {
        var c = new Image;
        return c.src = d.src, {
            width: c.width,
            height: c.height
        }
    }
    var q = window.SpriteSpin = {},
        p = q.namespace = "spritespin",
        o = ["mousedown", "mousemove", "mouseup", "mouseenter", "mouseover", "mouseleave", "dblclick", "touchstart", "touchmove", "touchend", "touchcancel", "selectstart", "gesturestart", "gesturechange", "gestureend"];
    q.mods = {}, q.defaults = {
        source: void 0,
        width: void 0,
        height: void 0,
        frames: void 0,
        framesX: void 0,
        lanes: 1,
        module: "360",
        behavior: "drag",
        renderer: "canvas",
        lane: 0,
        frame: 0,
        frameTime: 40,
        animate: !0,
        reverse: !1,
        loop: !0,
        stopFrame: 0,
        wrap: !0,
        wrapLane: !1,
        sense: 1,
        senseLane: void 0,
        orientation: "horizontal",
        onInit: void 0,
        onProgress: void 0,
        onLoad: void 0,
        onFrame: void 0,
        onDraw: void 0
    }, q.sourceArray = function(J, I) {
        var H = 0,
            G = 0,
            F = 0,
            E = 0,
            D = I.digits || 2;
        I.frame && (H = I.frame[0], G = I.frame[1]), I.lane && (F = I.lane[0], E = I.lane[1]);
        var C, n, m, b = [];
        for (C = F; E >= C; C += 1) {
            for (n = H; G >= n; n += 1) {
                m = J.replace("{lane}", A(C, D, 0)), m = m.replace("{frame}", A(n, D, 0)), b.push(m)
            }
        }
        return b
    }, q.measureSource = function(f) {
        var e = f.images[0],
            h = r(e);
        if (1 === f.images.length) {
            if (f.sourceWidth = h.width, f.sourceHeight = h.height, s(e, h) && (f.sourceWidth /= 2, f.sourceHeight /= 2), f.framesX = f.framesX || f.frames, !f.frameWidth || !f.frameHeight) {
                if (f.framesX) {
                    f.frameWidth = Math.floor(f.sourceWidth / f.framesX);
                    var g = Math.ceil(f.frames * f.lanes / f.framesX);
                    f.frameHeight = Math.floor(f.sourceHeight / g)
                } else {
                    f.frameWidth = h.width, f.frameHeight = h.height
                }
            }
        } else {
            f.sourceWidth = f.frameWidth = h.width, f.sourceHeight = f.frameHeight = h.height, s(e, h) && (f.sourceWidth = f.frameWidth = h.width / 2, f.sourceHeight = f.frameHeight = h.height / 2), f.frames = f.frames || f.images.length
        }
    }, q.resetInput = function(b) {
        b.startX = b.startY = void 0, b.currentX = b.currentY = void 0, b.oldX = b.oldY = void 0, b.dX = b.dY = b.dW = 0, b.ddX = b.ddY = b.ddW = 0
    }, q.updateInput = function(d, c) {
        void 0 === d.touches && void 0 !== d.originalEvent && (d.touches = d.originalEvent.touches), c.oldX = c.currentX, c.oldY = c.currentY, void 0 !== d.touches && d.touches.length > 0 ? (c.currentX = d.touches[0].clientX, c.currentY = d.touches[0].clientY) : (c.currentX = d.clientX, c.currentY = d.clientY), (void 0 === c.startX || void 0 === c.startY) && (c.startX = c.currentX, c.startY = c.currentY, c.clickframe = c.frame, c.clicklane = c.lane), c.dX = c.currentX - c.startX, c.dY = c.currentY - c.startY, c.ddX = c.currentX - c.oldX, c.ddY = c.currentY - c.oldY, c.ndX = c.dX / c.width, c.ndY = c.dY / c.height, c.nddX = c.ddX / c.width, c.nddY = c.ddY / c.height
    }, q.updateFrame = function(d, c, f) {
        void 0 !== c ? d.frame = Number(c) : d.animation && (d.frame += d.reverse ? -1 : 1), d.animation ? (d.frame = y(d.frame, 0, d.frames - 1, d.frames), d.loop || d.frame !== d.stopFrame || (d.animate = !1, q.stopAnimation(d))) : d.frame = d.wrap ? y(d.frame, 0, d.frames - 1, d.frames) : z(d.frame, 0, d.frames - 1), void 0 !== f && (d.lane = f, d.lane = z(d.lane, 0, d.lanes - 1)), d.target.trigger("onFrame", d), d.target.trigger("onDraw", d)
    }, q.stopAnimation = function(b) {
        b.animation && (window.clearInterval(b.animation), b.animation = null)
    }, q.setAnimation = function(b) {
        q.stopAnimation(b), b.animate && (b.animation = window.setInterval(function() {
            try {
                q.updateFrame(b)
            } catch (a) {}
        }, b.frameTime))
    }, q.setModules = function(a) {
        var h, g, f;
        for (h = 0; h < a.mods.length; h += 1) {
            g = a.mods[h], "string" == typeof g && (f = q.mods[g], f ? a.mods[h] = f : B.error("No module found with name " + g))
        }
    }, q.setLayout = function(f) {
        f.target.attr("unselectable", "on").css({
            "-ms-user-select": "none",
            "-moz-user-select": "none",
            "-khtml-user-select": "none",
            "-webkit-user-select": "none",
            "user-select": "none"
        });
        var e = Math.floor(f.width || f.frameWidth || f.target.innerWidth()),
            h = Math.floor(f.height || f.frameHeight || f.target.innerHeight());
        f.target.css({
            width: e,
            height: h,
            position: "relative",
            overflow: "hidden"
        });
        var g = {
            width: "100%",
            height: "100%",
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            position: "absolute"
        };
        f.stage.css(g).hide(), f.canvas && (f.canvas[0].width = e, f.canvas[0].height = h, f.canvas.css(g).hide())
    }, q.setEvents = function(g) {
        var e, j, i, h = g.target;
        for (u(h), j = 0; j < o.length; j += 1) {
            v(h, o[j], x)
        }
        for (e = 0; e < g.mods.length; e += 1) {
            for (i = g.mods[e], j = 0; j < o.length; j += 1) {
                v(h, o[j], i[o[j]])
            }
            v(h, "onInit", i.onInit), v(h, "onLoad", i.onLoad), v(h, "onFrame", i.onFrame), v(h, "onDraw", i.onDraw)
        }
        v(h, "onLoad", function(d, c) {
            q.setAnimation(c)
        }), v(h, "onInit", g.onInit), v(h, "onProgress", g.onProgress), v(h, "onLoad", g.onLoad), v(h, "onFrame", g.onFrame), v(h, "onDraw", g.onDraw)
    }, q.boot = function(b) {
        q.setModules(b), q.setLayout(b), q.setEvents(b), b.target.addClass("loading").trigger("onInit", b), t({
            source: b.source,
            progress: function(a) {
                b.target.trigger("onProgress", a)
            },
            complete: function(a) {
                b.images = a, q.measureSource(b), b.stage.show(), b.target.removeClass("loading").trigger("onLoad", b).trigger("onFrame", b).trigger("onDraw", b)
            }
        })
    }, q.create = function(a) {
        var h = a.target,
            g = h.data(p);
        if (g) {
            B.extend(g, a)
        } else {
            if (g = B.extend({}, q.defaults, a), g.source = g.source || [], h.find("img").each(function() {
                    g.source.push(B(this).attr("src"))
                }), h.empty().addClass("spritespin-instance").append("<div class='spritespin-stage'></div>"), "canvas" === g.renderer) {
                var f = B("<canvas class='spritespin-canvas'></canvas>")[0];
                f.getContext && f.getContext("2d") ? (g.canvas = B(f), g.context = f.getContext("2d"), h.append(g.canvas), h.addClass("with-canvas")) : g.renderer = "image"
            }
            g.target = h, g.stage = h.find(".spritespin-stage"), h.data(p, g)
        }
        "string" == typeof g.source && (g.source = [g.source]), (g.behavior || g.module) && (g.mods = [], g.behavior && g.mods.push(g.behavior), g.module && g.mods.push(g.module), delete g.behavior, delete g.module), q.boot(g)
    }, q.destroy = function(b) {
        b && (q.stopAnimation(b), u(b.target), b.target.removeData(p))
    }, q.registerModule = function(a, d) {
        return q.mods[a] && B.error("Module name is already taken: " + a), d = d || {}, q.mods[a] = d, d
    }, q.Api = function(b) {
        this.data = b
    }, q.extendApi = function(a) {
        var f, e = q.Api.prototype;
        for (f in a) {
            a.hasOwnProperty(f) && (e[f] ? B.error("API method is already defined: " + f) : e[f] = a[f])
        }
        return e
    }, B.fn.spritespin = function(a) {
        return "data" === a ? this.data(p) : "api" === a ? new q.Api(this.data(p)) : "destroy" === a ? B(this).each(function() {
            q.destroy(B(this).data(p))
        }) : "object" == typeof a ? (a.target = a.target || B(this), q.create(a), a.target) : B.error("Invalid call to spritespin")
    }
}(window.jQuery || window.Zepto || window.$),
function() {
    var b = window.SpriteSpin;
    b.extendApi({
        isPlaying: function() {
            return null !== this.data.animation
        },
        isLooping: function() {
            return this.data.loop
        },
        toggleAnimation: function() {
            this.data.animate = !this.data.animate, b.setAnimation(this.data)
        },
        stopAnimation: function() {
            this.data.animate = !1, b.setAnimation(this.data)
        },
        startAnimation: function() {
            this.data.animate = !0, b.setAnimation(this.data)
        },
        loop: function(a) {
            return this.data.loop = a, b.setAnimation(this.data), this
        },
        currentFrame: function() {
            return this.data.frame
        },
        updateFrame: function(a) {
            return b.updateFrame(this.data, a), this
        },
        skipFrames: function(a) {
            var d = this.data;
            return b.updateFrame(d, d.frame + (d.reverse ? -a : +a)), this
        },
        nextFrame: function() {
            return this.skipFrames(1)
        },
        prevFrame: function() {
            return this.skipFrames(-1)
        },
        playTo: function(a, l) {
            var k = this.data;
            if (l = l || {}, l.force || k.frame !== a) {
                if (l.nearest) {
                    var j = a - k.frame,
                        i = a > k.frame ? j - k.frames : j + k.frames,
                        h = Math.abs(j) < Math.abs(i) ? j : i;
                    k.reverse = 0 > h
                }
                return k.animate = !0, k.loop = !1, k.stopFrame = a, b.setAnimation(k), this
            }
        }
    })
}(window.jQuery || window.Zepto || window.$),
function(e, d) {
    function f(j) {
        var i = e(this),
            h = i.data("spritespin");
        d.updateInput(j, h);
        var b, a;
        "horizontal" === h.orientation ? (b = h.target.innerWidth() / 2, a = h.currentX - h.target.offset().left) : (b = h.target.innerHeight() / 2, a = h.currentY - h.target.offset().top), a > b ? i.spritespin("next") : i.spritespin("prev")
    }
    d.registerModule("click", {
        mouseup: f,
        touchend: f
    })
}(window.jQuery || window.Zepto || window.$, window.SpriteSpin),
function(g, f) {
    function j(b) {
        var a = g(this).spritespin("data");
        f.updateInput(b, a), a.dragging = !0
    }

    function i() {
        var b = g(this),
            a = b.spritespin("data");
        f.resetInput(a), a.dragging = !1
    }

    function h(x) {
        var w, v, u, t, s = g(this),
            r = s.spritespin("data");
        if (r.dragging) {
            f.updateInput(x, r);
            var q = 0;
            q = "number" == typeof r.orientation ? (Number(r.orientation) || 0) * Math.PI / 180 : "horizontal" === r.orientation ? 0 : Math.PI / 2;
            var p = Math.sin(q),
                o = Math.cos(q),
                b = r.ndX * o - r.ndY * p,
                a = r.ndX * p + r.ndY * o;
            w = b * r.frames * r.sense, v = a * r.lanes * (r.senseLane || r.sense), t = Math.floor(r.clickframe + w), u = Math.floor(r.clicklane + v), f.updateFrame(r, t, u), r.animate = !1, f.stopAnimation(r)
        }
    }
    f.registerModule("drag", {
        mousedown: j,
        mousemove: h,
        mouseup: i,
        mouseleave: i,
        touchstart: j,
        touchmove: h,
        touchend: i,
        touchcancel: i
    }), f.registerModule("move", {
        mousemove: function(b) {
            j.call(this, b), h.call(this, b)
        },
        mouseleave: i,
        touchstart: j,
        touchmove: h,
        touchend: i,
        touchcancel: i
    })
}(window.jQuery || window.Zepto || window.$, window.SpriteSpin),
function(g, f) {
    function j(k) {
        var b = g(this),
            a = b.spritespin("data");
        f.updateInput(k, a), a.onDrag = !0, b.spritespin("animate", !0)
    }

    function i() {
        var b = g(this),
            a = b.spritespin("data");
        f.resetInput(a), a.onDrag = !1, b.spritespin("animate", !1)
    }

    function h(m) {
        var l = g(this),
            k = l.spritespin("data");
        if (k.onDrag) {
            f.updateInput(m, k);
            var b, a;
            "horizontal" === k.orientation ? (b = k.target.innerWidth() / 2, a = (k.currentX - k.target.offset().left - b) / b) : (b = k.height / 2, a = (k.currentY - k.target.offset().top - b) / b), k.reverse = 0 > a, a = 0 > a ? -a : a, k.frameTime = 80 * (1 - a) + 20
        }
    }
    f.registerModule("hold", {
        mousedown: j,
        mousemove: h,
        mouseup: i,
        mouseleave: i,
        touchstart: j,
        touchmove: h,
        touchend: i,
        touchcancel: i,
        onFrame: function() {
            var a = g(this);
            a.spritespin("animate", !0)
        }
    })
}(window.jQuery || window.Zepto || window.$, window.SpriteSpin),
function(g, f) {
    function j(k) {
        var b = g(this),
            a = b.spritespin("data");
        f.updateInput(k, a), a.onDrag = !0
    }

    function i() {
        var b = g(this),
            a = b.spritespin("data");
        a.onDrag = !1, f.resetInput(a)
    }

    function h(o) {
        var n = g(this),
            m = n.spritespin("data");
        if (m.onDrag) {
            f.updateInput(o, m);
            var l, k, b = m.frame,
                a = m.snap || 0.25;
            "horizontal" === m.orientation ? (l = m.dX, k = m.target.innerWidth() * a) : (l = m.dY, k = m.target.innerHeight() * a), l > k ? (b = m.frame - 1, m.onDrag = !1) : -k > l && (b = m.frame + 1, m.onDrag = !1), n.spritespin("update", b), n.spritespin("animate", !1)
        }
    }
    f.registerModule("swipe", {
        mousedown: j,
        mousemove: h,
        mouseup: i,
        mouseleave: i,
        touchstart: j,
        touchmove: h,
        touchend: i,
        touchcancel: i
    })
}(window.jQuery || window.Zepto || window.$, window.SpriteSpin),
function(g, f) {
    function j(a) {
        var l = a.lane * a.frames + a.frame,
            k = a.frameWidth * (l % a.framesX),
            e = a.frameHeight * h(l / a.framesX);
        return "canvas" === a.renderer ? (a.context.clearRect(0, 0, a.width, a.height), a.context.drawImage(a.images[0], k, e, a.frameWidth, a.frameHeight, 0, 0, a.width, a.height), void 0) : (k = -h(k * a.scaleWidth), e = -h(e * a.scaleHeight), "background" === a.renderer ? a.stage.css({
            "background-image": ["url('", a.source[0], "')"].join(""),
            "background-position": [k, "px ", e, "px"].join("")
        }) : g(a.images).css({
            top: e,
            left: k
        }), void 0)
    }

    function i(a) {
        var d = a.lane * a.frames + a.frame;
        "canvas" === a.renderer ? (a.context.clearRect(0, 0, a.width, a.height), a.context.drawImage(a.images[d], 0, 0, a.width, a.height)) : "background" === a.renderer ? a.stage.css({
            "background-image": ["url('", a.source[d], "')"].join(""),
            "background-position": [0, "px ", 0, "px"].join("")
        }) : (g(a.images).hide(), g(a.images[d]).show())
    }
    var h = Math.floor;
    f.registerModule("360", {
        onLoad: function(a, m) {
            var l, k;
            if (m.scaleWidth = m.width / m.frameWidth, m.scaleHeight = m.height / m.frameHeight, m.sourceIsSprite = 1 === m.images.length, m.stage.empty().css({
                    "background-image": "none"
                }).show(), "canvas" === m.renderer) {
                m.context.clearRect(0, 0, m.width, m.height), m.canvas.show()
            } else {
                if ("background" === m.renderer) {
                    m.sourceIsSprite ? (l = h(m.sourceWidth * m.scaleWidth), k = h(m.sourceHeight * m.scaleHeight)) : (l = h(m.frameWidth * m.scaleWidth), k = h(m.frameHeight * m.scaleHeight));
                    var e = [l, "px ", k, "px"].join("");
                    m.stage.css({
                        "background-repeat": "no-repeat",
                        "-webkit-background-size": e,
                        "-moz-background-size": e,
                        "-o-background-size": e,
                        "background-size": e
                    })
                } else {
                    "image" === m.renderer && (m.sourceIsSprite ? (l = h(m.sourceWidth * m.scaleWidth), k = h(m.sourceHeight * m.scaleHeight)) : l = k = "100%", g(m.images).appendTo(m.stage).css({
                        width: l,
                        height: k,
                        position: "absolute"
                    }))
                }
            }
        },
        onDraw: function(d, c) {
            c.sourceIsSprite ? j(c) : i(c)
        }
    })
}(window.jQuery || window.Zepto || window.$, window.SpriteSpin),
function(d) {
    var c = window.SpriteSpin.mods.gallery = {};
    c.onLoad = function(a, j) {
        j.images = [], j.offsets = [], j.stage.empty(), j.speed = 500, j.opacity = 0.25, j.oldFrame = 0;
        var i, h = 0;
        for (i = 0; i < j.source.length; i += 1) {
            var g = d("<img src='" + j.source[i] + "'/>");
            j.stage.append(g), j.images.push(g), j.offsets.push(-h + (j.width - g[0].width) / 2), h += g[0].width, g.css({
                opacity: 0.25
            })
        }
        j.stage.css({
            width: h
        }), j.images[j.oldFrame].animate({
            opacity: 1
        }, j.speed)
    }, c.onDraw = function(f, e) {
        e.oldFrame !== e.frame && e.offsets ? (e.stage.stop(!0, !1), e.stage.animate({
            left: e.offsets[e.frame]
        }, e.speed), e.images[e.oldFrame].animate({
            opacity: e.opacity
        }, e.speed), e.oldFrame = e.frame, e.images[e.oldFrame].animate({
            opacity: 1
        }, e.speed)) : e.stage.css({
            left: e.offsets[e.frame] + e.dX
        })
    }, c.resetInput = function(f, e) {
        e.onDrag || e.stage.animate({
            left: e.offsets[e.frame]
        })
    }
}(window.jQuery || window.Zepto || window.$),
function(e, d) {
    var f = Math.floor;
    d.registerModule("panorama", {
        onLoad: function(g, c) {
            c.stage.empty().show(), c.frames = c.sourceWidth, "horizontal" === c.orientation ? (c.scale = c.height / c.sourceHeight, c.frames = c.sourceWidth) : (c.scale = c.width / c.sourceWidth, c.frames = c.sourceHeight);
            var j = f(c.sourceWidth * c.scale),
                i = f(c.sourceHeight * c.scale),
                h = [j, "px ", i, "px"].join("");
            c.stage.css({
                "background-image": ["url('", c.source[0], "')"].join(""),
                "background-repeat": "repeat-both",
                "-webkit-background-size": h,
                "-moz-background-size": h,
                "-o-background-size": h,
                "background-size": h
            })
        },
        onDraw: function(g, c) {
            var i = 0,
                h = 0;
            "horizontal" === c.orientation ? i = -f(c.frame % c.frames * c.scale) : h = -f(c.frame % c.frames * c.scale), c.stage.css({
                "background-position": [i, "px ", h, "px"].join("")
            })
        }
    })
}(window.jQuery || window.Zepto || window.$, window.SpriteSpin);
shared.Common = (function(b) {
    function c() {
        a()
    }

    function a() {
        console.log("Common: checkCookiesSettings()");
        if (navigator.cookieEnabled === false) {
            var d = shared.Pattern.returnHtml("systemMessage");
            d = shared.Misc.replacePlaceholderInString(d, ["caution", "attention", local.noCookies]);
            b(".header").prepend('<div class="useragent-warning"><div class="container">' + d + "</div></div>")
        }
    }
    return {
        init: c
    }
}(jQuery));
shared.Misc = (function(u) {
    function G(S) {
        console.log("shared.Misc:init()");
        var P = S.find(".js__setFocus"),
            Z = S.find(".js__modifyHtmlElement"),
            Y = S.find(".js__setSameHeight"),
            aa = S.find("img:not([data-lazy-src])"),
            ab = S.find(".js__triggerEvent"),
            X = S.find(".js__toggleContent-link"),
            V = S.find(".js__goToPreviousPage"),
            O = S.find(".js__goToUrl"),
            W = S.find(".js__switchContent"),
            Q = S.find(".js__startAjaxRequest"),
            R = S.find(".js__openFlyout"),
            M = S.find(".js__jumpToContent"),
            L = S.find("[data-prevent]"),
            T = S.find(".icon--information"),
            N = S.find(".js__filterUrl"),
            U = S.find(".js__showMoreContent");
        var K = "a[data-prevent], button[data-prevent], input[data-prevent], .icon--information";
        if (P.length > 0) {
            o(P)
        }
        if (N.length > 0) {
            D(N)
        }
        if (M.length > 0) {
            m(M)
        }
        if (V.length > 0) {
            p(V)
        }
        if (Q.length > 0) {
            k(Q)
        }
        if (O.length > 0) {
            x(O)
        }
        if (Z.length > 0) {
            l(Z)
        }
        if (ab.length > 0) {
            n(ab)
        }
        if (aa.length > 0) {
            j(aa)
        }
        if (X.length > 0) {
            t(X)
        }
        if (Y.length > 0) {
            u.each(Y, function() {
                s(u(this))
            })
        }
        if (R.length > 0) {
            z(R)
        }
        L.on("click", function(ad) {
            var ac = u(this);
            if (ac.data("prevent") && ac.attr("data-prevent")) {
                ad.preventDefault()
            }
        });
        T.on("click", function(ac) {
            ac.preventDefault()
        });
        if (W.length > 0) {
            B(W);
            u.each(W, function() {
                var ac = u(this);
                if ((this.tagName == "INPUT" && !ac.prop("checked"))) {
                    return
                }
                if (ac.val() != "") {
                    b(this, true)
                } else {
                    if (ac.val() == "" && ac.find("option:selected").data("switch-target")) {
                        b(this, true)
                    }
                }
            })
        }
        if (U.length > 0) {
            A(U)
        }
        g()
    }

    function g() {
        console.log("shared.Misc: addOpenFlyoutViaUrlParameterListener()");
        var M = u(location).attr("hash");
        var K = flyouts.hasOwnProperty(M);
        if (K) {
            var L = u('<a href="' + M + '" data-open-flyout="' + flyouts[M] + '"></a>');
            H(L)
        }
    }

    function m(L) {
        console.log("shared.Misc: addJumpToContentListener()");
        var K;
        u.each(L, function() {
            var M = u(this);
            if (this.tagName == "SELECT") {
                M.on("change", function(N) {
                    N.preventDefault();
                    K = u(M.val());
                    context.Misc.jumpToContent(K, true)
                })
            } else {
                M.on("click", function(N) {
                    N.preventDefault();
                    K = u(M.attr("href"));
                    context.Misc.jumpToContent(K, true)
                })
            }
        })
    }

    function h(K) {
        console.log("shared.Misc: addLazyLoadListener()");
        u.each(K, function() {
            var L = u(this);
            L.on("inview", function() {
                var M = u(this);
                if (this.tagName == "IMG") {
                    c(u(this))
                } else {
                    u.each(M.find("img[data-lazy-src]"), function() {
                        c(u(this))
                    })
                }
                M.removeClass("lazy-load").off("inview")
            })
        })
    }

    function k(K) {
        console.log("shared.Misc: addStartAjaxRequestListener()");
        u.each(K, function() {
            var N = u(this),
                L = N.attr("type"),
                M = L == "checkbox" || this.tagName == "SELECT" ? "change" : "click";
            N.on(M, function(O) {
                O.preventDefault();
                context.Misc.startAjaxRequest(N, M)
            })
        })
    }

    function B(K) {
        console.log("shared.Misc: addSwitchContentListener()");
        K.on("change", function() {
            shared.Misc.switchContent(this)
        })
    }

    function x(K) {
        console.log("shared.Misc: addGoToUrlListener()");
        K.on("change", function(M) {
            M.preventDefault();
            var L = u(this);
            I(L, L.data("append"))
        })
    }

    function o(K) {
        console.log("shared.Misc: addSetFocusListener()");
        u.each(K, function() {
            var N = u(this),
                M = this.tagName,
                L = M == "A" ? "click" : "change";
            N.on(L, function() {
                var P = u(this),
                    O = u("#" + P.data("set-focus"));
                setTimeout(function() {
                    y(O)
                }, 100)
            })
        })
    }

    function l(K) {
        console.log("shared.Misc: getJsonForModifyHtmlElement()");
        u.each(K, function() {
            var N = u(this),
                L = N.data("modify-url"),
                M = N.data("modify-parent");
            u.ajax({
                url: L,
                success: function(O) {
                    if (O.modifyHtmlElement) {
                        w(O.modifyHtmlElement, M)
                    }
                }
            })
        })
    }

    function n(K) {
        console.log("shared.Misc: addTriggerEventListener()");
        K.on("click", function(O) {
            O.preventDefault();
            O.stopPropagation();
            var N = u(this),
                L = u(N.attr("href")),
                M = N.data("trigger-event");
            L.trigger(M)
        })
    }

    function t(K) {
        console.log("shared.Misc: addToggleContentListener()");
        K.on("click", function(L) {
            L.preventDefault();
            q(u(this))
        })
    }

    function z(K) {
        console.log("shared.Misc: addOpenFlyoutListener()");
        K.on("click", function(L) {
            H(K)
        })
    }

    function A(K) {
        console.log("shared.Misc: showMoreContentListener()");
        K.on("click", function() {
            var L;
            var N = K.data("height");
            var M = u("." + K.data("container"));
            if (K.hasClass("more")) {
                K.html(local.showLess + "&hellip;").removeClass("more");
                M.addClass("full");
                L = "auto"
            } else {
                K.html(local.showMore + "&hellip;").addClass("more");
                M.removeClass("full");
                L = N
            }
            M.css("height", L)
        })
    }

    function A(K) {
        console.log("shared.Misc: showMoreContentListener()");
        K.on("click", function() {
            var L;
            var N = K.data("height");
            var M = u("." + K.data("container"));
            if (K.hasClass("more")) {
                K.html(local.showLess + "&hellip;").removeClass("more");
                M.addClass("full");
                L = "auto"
            } else {
                K.html(local.showMore + "&hellip;").addClass("more");
                M.removeClass("full");
                L = N
            }
            M.css("height", L)
        })
    }

    function j(L, K) {
        console.log("shared.Misc: detectBrokenImage()");
        L.on("load.detection error.detection", function(P) {
            var O = u(this),
                N = u('img[data-lazy-src="' + K + '"]'),
                M;
            if (O.attr("width") && O.attr("height")) {
                M = O.attr("width") + "x" + O.attr("height")
            } else {
                M = "72x72"
            }
            L.data("lazy-src", null).removeAttr("data-lazy-src");
            N.attr("src", L.attr("src")).data("lazy-src", "").removeAttr("data-lazy-src").off("inview");
            if (P.type === "error") {
                E(O, M);
                E(N, M)
            } else {
                O.removeClass("lazy-load")
            }
            O.off("error.detection load.detection")
        })
    }

    function C() {
        console.log("shared.Misc: cancelRunningXhrs()");
        u.each(runningXhr, function() {
            this.abort();
            shared.Helper.removeItemFromArray(runningXhr, this)
        })
    }

    function c(L) {
        console.log("shared.Misc: lazyLoadImage()");
        var K = L.data("lazy-src");
        L.attr("src", K);
        if (L.data("error-detection-done") !== true) {
            j(L, K);
            L.data("error-detection-done", true)
        }
    }

    function E(L, K) {
        console.log("shared.Misc: markImageAsBroken()");
        L.addClass("image--broken image--broken-" + K);
        L.attr("src", files.image["transparency"])
    }

    function v(L, K) {
        console.log("shared.Misc: replacePlaceholderInString()");
        var L;
        u.each(K, function() {
            L = L.replace("%REPLACE%", this)
        });
        return L
    }

    function b(M, U) {
        console.log("shared.Misc: switchContent()");
        var Q = u(M),
            R = Q.closest("form").length == 0 ? Q.closest(".switch-content-container") : false,
            T = shared.Forms.getOptionsGroups(Q, R),
            K = (M.tagName == "SELECT" ? Q.find("option:selected") : T[0].filter(":checked")),
            O = Q.data("switch").split(","),
            S = K.data("switch-target") || "",
            L = Q.closest(".switch-content-container").data("switch-active-class"),
            N, P = [];
        if (L && !K.closest(L).hasClass("active")) {
            u.each(T, function() {
                u(this).closest(L).removeClass("active")
            });
            K.closest(L).addClass("active")
        }
        if (S.length > 0) {
            N = S.split(",")
        } else {
            N = [""]
        }
        u.each(O, function(W) {
            O[W] = O[W].trim();
            var V = Q.closest(".switch-content-container").find("." + O[W]);
            u.each(V, function() {
                var Y = u(this),
                    X = Y.data("switch-check") || "",
                    Z = u("#" + X);
                if (Z.length > 0 && Z.is(":checked")) {
                    if (!U) {
                        Z.prop("disabled", true).prop("checked", false).trigger("change")
                    }
                } else {
                    Y.removeClass("active")
                }
            });
            P[W] = N[W] !== undefined ? N[W] : ""
        });
        u.each(P, function(X) {
            if (P[X].length > 0) {
                P[X] = P[X].trim();
                var V = Q.closest(".switch-content-container").find('.switch-content[data-switch-content="' + P[X] + '"]'),
                    W = V.find(".js__switchContent:checked");
                V.addClass("active");
                if (V.data("switch-check")) {
                    u("#" + V.data("switch-check")).prop("disabled", false)
                }
                if (W.length > 0) {
                    W.trigger("change")
                }
                if (V.find(".js__setSameHeight") && typeof louis != "undefined") {
                    u.each(V.find(".js__setSameHeight"), function() {
                        louis.Misc.setSameHeight(u(this))
                    })
                }
            }
        })
    }

    function d(K) {
        console.log("shared.Misc: changeTab()");
        var M = K.closest(".js__tab-system"),
            L = typeof M.data("hide-tab") == "undefined" ? false : M.data("hide-tab");
        if (K.hasClass("active") && L) {
            K.add(M.find(".tab-navigation .active")).removeClass("active")
        } else {
            M.find(".tab-navigation .active, .tab.active").removeClass("active");
            M.find('.tab-navigation a[href="#' + K.attr("id") + '"]').parent().addClass("active");
            K.addClass("active");
            if (K.closest("js__tab-system").data("sethash")) {
                var N = K.attr("id");
                K.removeAttr("id");
                window.location.hash = N;
                K.attr("id", N)
            }
        }
    }

    function y(K) {
        console.log("shared.Misc: setFocus()");
        K.focus()
    }

    function I(P, M) {
        console.log("shared.Misc: goToUrl()");
        var N = P.val();
        if (M) {
            var V, L = P.attr("name"),
                O = false,
                Q = P.find("option:selected"),
                U = [];
            try {
                V = decodeURI(window.location.href)
            } catch (T) {
                V = window.location.href
            }
            V = V.replace(/(<([^>]+)>)/ig, "");
            if (V.indexOf("#") > 0) {
                var S = V.indexOf("#"),
                    R = V.substr(S);
                V = V.replace(R, "")
            }
            if (V.indexOf("?") > 0) {
                O = shared.Misc.makeArrayFromParamsList(V.substr(V.indexOf("?") + 1))
            }
            if (O) {
                var K = V.substr(0, V.indexOf("?"));
                if (u.inArray(L, O) < 0) {
                    O.push(L)
                }
                O[L] = N;
                if (Q.data("ignore")) {
                    U.push(Q.data("ignore"))
                }
                url = K + "?";
                u.each(O, function(W) {
                    var X = O[W];
                    if ((!U || U != O[W]) && O[X] != undefined) {
                        url += O[W] + "=" + O[X];
                        if (W + 1 < O.length) {
                            url += "&"
                        }
                    }
                })
            } else {
                url = window.location.href + "?" + P.attr("name") + "=" + N
            }
            if (P.data("anchor")) {
                url += P.data("anchor")
            }
        } else {
            url = N
        }
        window.location.href = url
    }

    function p(K) {
        console.log("shared.Misc: addGoToPreviousPageListener()");
        K.on("click", function(L) {
            L.preventDefault();
            i()
        })
    }

    function i() {
        console.log("shared.Misc: goToPreviousPage()");
        history.back()
    }

    function F(O) {
        var N = [],
            M, K = O.split("&"),
            L;
        for (L = 0; L < K.length; L++) {
            M = K[L].split("=");
            N.push(M[0]);
            N[M[0]] = M[1]
        }
        return N
    }

    function w(K, L) {
        console.log("shared.Misc: modifyHtmlElement()");
        u.each(K, function(N, O) {
            var M;
            if (L) {
                M = u(window.opener.document.getElementById(N))
            } else {
                M = u("#" + N)
            }
            if (M.length > 0) {
                u.each(O, function(P, T) {
                    var S = false,
                        Q;
                    if (P == "innerHtml") {
                        M.html(T);
                        S = true;
                        Q = M
                    } else {
                        if (P == "replaceHtml") {
                            M.replaceWith(T);
                            S = true;
                            Q = M
                        } else {
                            if (P == "appendHtml") {
                                $newEl = u(T);
                                M = M.after(T);
                                S = true;
                                Q = $newEl
                            } else {
                                if (P == "addClass") {
                                    M.addClass(T)
                                } else {
                                    if (P == "removeClass") {
                                        M.removeClass(T)
                                    } else {
                                        if (P == "addAttribute") {
                                            M.attr(T.attr, T.value)
                                        } else {
                                            if (P == "removeAttribute") {
                                                if (T.attr.indexOf("data-") == 0) {
                                                    var R = T.attr.replace("data-", "");
                                                    M.removeData(R)
                                                }
                                                M.removeAttr(T.attr)
                                            } else {
                                                M.prop(P, T)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (S && Q.length > 0) {
                        context.Misc.init(Q);
                        G(Q);
                        context.Forms.init(Q);
                        shared.Forms.init(Q);
                        if (typeof louis == "undefined") {
                            shared.RequestData.BikeDb.init(Q.find(".add-new-bike-form"))
                        }
                    }
                })
            }
        })
    }

    function f(L) {
        console.log("shared.Misc: keepOrRemoveClosedAppendedContent()");
        if (L.data("mustrevalidate")) {
            L.remove()
        } else {
            var M = typeof L.attr("id") != "undefined" ? L.attr("id") : L.find("> div").attr("id"),
                K = u('a[href="#' + M + '"]');
            if (K.attr("data-ajax")) {
                K.removeAttr("data-ajax").data("ajax", false)
            }
        }
    }

    function J(K) {
        console.log("shared.Misc: replaceForAjaxCalls()");
        u.each(K, function(T, S) {
            var Q = u("#" + T),
                M = Q.data("url") || "",
                P = [],
                N = [],
                R, L;
            if (M.indexOf("?") > 0) {
                N = shared.Misc.makeArrayFromParamsList(M.substr(M.indexOf("?") + 1));
                L = M.substr(0, M.indexOf("?"))
            } else {
                L = M
            }
            u.each(S, function(U, V) {
                P.push(U);
                P[U] = V
            });
            R = L + "?";
            if (N.length > 0) {
                u.each(P, function(V) {
                    var U = P[V];
                    if (jQuery.inArray(U, N) >= 0) {
                        N[U] = P[U]
                    }
                });
                u.each(N, function(U) {
                    var V = N[U];
                    R += N[U] + "=" + N[V];
                    if (U < N.length - 1) {
                        R += "&"
                    }
                })
            } else {
                var O = 0;
                u.each(P, function(U, V) {
                    R += U + "=" + V;
                    if (O < N.length - 1) {
                        R += "&"
                    }
                    O++
                })
            }
            Q.data("url", R)
        })
    }

    function q(N) {
        console.log("shared.Misc: toggleContent()");
        var K = N.closest(".js__toggleContent"),
            M = K.find(".js__toggleContent-item"),
            L = M.find(".js__toggleContent-setFocus");
        M.toggleClass("hidden");
        if (L.length > 0) {
            shared.Forms.focusInput(L);
            shared.Forms.selectInput(L)
        }
        if (K.hasClass(".js__setSameHeight") || K.parents(".js__setSameHeight").length > 0) {
            s()
        }
    }

    function s(O, P, N) {
        console.log("shared.Misc: setSameHeight()");
        var M = [],
            K = P || O.find(".js__setSameHeight-item"),
            L;
        K.each(function() {
            var R = u(this),
                Q = R.outerHeight();
            M.push(Q)
        });
        if (!M.AllValuesSame()) {
            L = Math.max.apply(null, M);
            K.each(function() {
                var R = u(this),
                    Q = 0;
                if (!N) {
                    Q = parseInt(R.css("padding-top"), 10) + parseInt(R.css("padding-bottom"), 10)
                }
                R.css("min-height", L - Q)
            })
        }
    }

    function r() {
        console.log("shared.Misc: reloadPageWithParam()");
        var K = decodeURI(window.location.href).replace(/(<([^>]+)>)/ig, ""),
            L;
        if (K.indexOf("pagereload=true") > 0) {
            window.location.reload()
        } else {
            if (K.indexOf("?") > 0) {
                L = K + "&"
            } else {
                L = K + "?"
            }
            window.location.href = L + "pagereload=true"
        }
    }

    function H(K) {
        console.log("shared.Misc: openFlyout()");
        var M = K.attr("href");
        var L = K.data("open-flyout");
        if (!u(L).hasClass("active")) {
            d(u(L));
            u(M).addClass("active")
        }
    }

    function e(L, N, K, M) {
        console.log("shared.Misc: sendGoogleAnalyticsEvents - " + L + " " + N + " " + K + " " + M);
        if (M != null) {
            ga("send", "event", L, N, K, M)
        } else {
            if (K != null) {
                ga("send", "event", L, N, K)
            } else {
                ga("send", "event", L, N)
            }
        }
    }

    function a(K) {
        console.log("shared.Misc: bindGoogleAnalyticEvents()");
        if (typeof K != "undefined") {
            u.each(K, function() {
                var L = this;
                if (L.documentObjectId == "window") {
                    var M = window
                } else {
                    var M = L.documentObjectId
                }
                if ("1" == u(M).data("gaevent")) {
                    return
                }
                if (L.event == "inview") {
                    u(M).data("gaevent", "1");
                    u(M).bind("inview", function(N, P, O) {
                        if (P == true) {
                            if (O != "top" && O != "bottom") {
                                e(L.category, L.action, L.label, L.value)
                            }
                        }
                    })
                } else {
                    u(M).data("gaevent", "1");
                    u(M).on(L.event, function() {
                        e(L.category, L.action, L.label, L.value)
                    })
                }
            })
        }
    }

    function D(K) {
        console.log("shared.Misc: addFilterUrlListener()");
        K.each(function() {
            u(this).on("click", function(M) {
                M.preventDefault();
                var L = u(this).data("href");
                window.open(L)
            })
        })
    }
    return {
        init: G,
        addLazyLoadListener: h,
        addSwitchContentListener: B,
        makeArrayFromParamsList: F,
        modifyHtmlElement: w,
        switchContent: b,
        changeTab: d,
        setFocus: y,
        setSameHeight: s,
        toggleContent: q,
        markImageAsBroken: E,
        replacePlaceholderInString: v,
        keepOrRemoveClosedAppendedContent: f,
        replaceForAjaxCalls: J,
        reloadPageWithParam: r,
        goToUrl: I,
        detectBrokenImage: j,
        cancelRunningXhrs: C,
        bindGoogleAnalyticEvents: a,
        sendGoogleAnalyticsEvents: e
    }
}(jQuery));
shared.Forms = (function(f) {
    function A(R) {
        var N = R.find(".js__getNewCaptcha"),
            V = R.find(".js__submitForm"),
            X = R.find(".js__urlParamsOnSubmit"),
            T = R.find(".js__setAttribute"),
            aa = R.find(".count-chars"),
            K = R.find('input[type="number"]'),
            M = R.find(".js__toggleDisabledState"),
            Z = R.find(".js__toggleValidation"),
            U = R.find(".js__pasteValueInElement"),
            J = R.find(".js__toggleErrorClassToErrorMessage"),
            Q = R.find(".js__toggleSingleValidation"),
            S = R.find('[type="submit"], .submit-button'),
            W = R.find(".inner-form input, .inner-form select"),
            L = R.find(".js__enableInputs");
        if (K.length > 0 && !supportsHtml5InputTypeValidation && (typeof Modernizr == "undefined" || !Modernizr.touch)) {
            f.each(K, function() {
                var ac = f(this),
                    ab = ac.data("max") || (ac.attr("max") ? ac.attr("max").length : null);
                ac.prop("type", "text");
                if (ab) {
                    ac.prop("maxlength", ab)
                }
                if (ac.attr("max")) {
                    ac.removeAttr("max")
                }
                if (ac.attr("min")) {
                    ac.removeAttr("min")
                }
                if (ac.attr("step")) {
                    ac.removeAttr("step")
                }
            })
        } else {
            f.each(K, function() {
                var ab = f(this);
                if (ab.data("max") && ab.attr("max")) {
                    ab.data("max", false).removeAttr("data-max")
                }
            })
        }
        if (Q.length > 0) {
            var P = e(Q);
            f.each(P, function(ab) {
                var ac = P[ab].closest("form").find('select[name*="salutation"]').val() == "FIRMA";
                if (ac) {
                    I(P[ab], false)
                }
            });
            g(P)
        }
        if (W.length > 0) {
            q(W)
        }
        if (U.length > 0) {
            F(U)
        }
        if (J.length > 0) {
            var Y = e(J);
            y(Y)
        }
        if (M.length > 0) {
            var Y = e(M);
            f.each(Y, function(ac) {
                var ab = Y[ac][0].tagName,
                    ad = ab == "SELECT" ? Y[ac].find("option") : Y[ac];
                a(ad, ab, true)
            });
            w(Y)
        }
        if (Z.length > 0) {
            var O = Z.closest("form").length == 0 ? Z.closest(".switch-content-container") : false;
            var Y = e(Z, O);
            f.each(Y, function(ab) {
                H(Y[ab], Y[ab][0].tagName)
            });
            s(Y)
        }
        if (N.length > 0) {
            r(N)
        }
        if (V.length > 0) {
            c(V)
        }
        if (X.length > 0) {
            v(X)
        }
        if (aa.length > 0) {
            t(aa);
            k(aa)
        }
        if (T.length > 0) {
            b(T)
        }
        if (S.length > 0) {
//            B(S)
        }
        if (L.length > 0) {
            m(L)
        }
        shared.Forms.Validation.init(R)
    }

    // function B(J) {
    //     console.log("shared.Forms: addSubmitListener()");
    //     J.on("click", function() {
    //         var L = f(this),
    //             K = L.closest("form");
    //         i(K, L);
    //         if (L.data("form-action")) {
    //             j(L.data("form-action"), K)
    //         }
    //     })
    // }

    function q(J) {
        console.log("shared.Forms: addInnerFormInputsListener()");
        J.on("keypress", function(L) {
            if (L.which === 13) {
                var K = f(this);
                K.closest(".inner-form").find(".submit-button").prop("type", "submit");
                i(K.closest(".inner-form"), K.closest(".inner-form").find(".submit-button"))
            }
        })
    }

    function g(J) {
        console.log("shared.Forms: addToggleSingleValidationListener()");
        f.each(J, function(L) {
            var K = J[L].closest("form").find('select[name*="salutation"]');
            K.on("change", function() {
                var M = K.val() !== "FIRMA";
                I(J[L], M)
            })
        })
    }

    function y(J) {
        console.log("shared.Forms: addToggleErrorClassToErrorMessageListener()");
        f.each(J, function(K) {
            var L = J[K];
            L.on("change", function() {
                var M = f(this);
                o(M, L)
            })
        })
    }

    function F(J) {
        console.log("shared.Forms: addPasteValueInElementListener()");
        J.on("change", function() {
            var K = f.parseJSON(E(f(this)));
            shared.Misc.modifyHtmlElement(K)
        })
    }

    function w(J) {
        console.log("shared.Forms: addChangeDisabledStateOfFormElementsListener()");
        f.each(J, function(K) {
            J[K].on("change", function() {
                var N = f(this),
                    L = this.tagName,
                    M = L == "SELECT" ? N.find("option") : J[K];
                a(M, L)
            })
        })
    }

    function s(J) {
        console.log("shared.Forms: addToggleValidationListener()");
        f.each(J, function(K) {
            J[K].on("change", function() {
                var N = f(this),
                    L = this.tagName,
                    M = L == "SELECT" ? N : N.closest("form").find('[name="' + N.attr("name") + '"]');
                H(M, L)
            })
        })
    }

    function b(J) {
        console.log("shared.Forms: addSetAttributeListener()");
        J.on("change", function() {
            p(f(this))
        })
    }

    function v(J) {
        console.log("shared.Forms: addUrlParamsOnSubmitListener()");
        f.each(J, function() {
            var K = f(this);
            K.on("submit", function(L) {
                u(K.closest("form"))
            })
        })
    }

    function c(J) {
        console.log("shared.Forms: addSubmitFormListener()");
        f.each(J, function() {
            var M = f(this),
                L = this.tagName,
                K = L === "A" ? "click" : "change";
            M.on(K, function(O) {
                O.preventDefault();
                var N = f(this);
                n(N.closest("form"), "", N.data("addurlparams"))
            })
        })
    }

    function t(J) {
        console.log("shared.Forms: addCountCharsListener()");
        J.on("keyup", function() {
            var K = f(this);
            setTimeout(function() {
                k(K)
            }, 100)
        })
    }

    function r(J) {
        console.log("shared.Forms: addGetNewCaptchaListener()");
        J.on("click", function(K) {
            K.preventDefault();
            z(J)
        })
    }

    function m(J) {
        console.log("shared.Forms: addEnableInputsListener()");
        J.find(".js__enableInputs-item").on("change", function() {
            h(f(this), J)
        })
    }

    function j(K, J) {
        console.log("shared.Forms: changeFormAction()");
        J.prop("action", K)
    }

    function i(J, K) {
        console.log("shared.Forms: addSubmitButtonAsHiddenInput()");
        J.append('<input class="clicked-button" type="hidden" name="' + K.prop("name") + '">')
    }

    function I(J, L) {
        console.log("shared.Forms: changeElementValidationState()");
        var K = J.closest(".input-container").find(".required-marker");
        if (!L) {
            K.addClass("hidden")
        } else {
            K.removeClass("hidden")
        }
    }

    function o(L, K) {
        console.log("shared.Forms: toggleErrorClassToErrorMessage()");
        var J = f("#" + L.data("error-message"));
        if (K.filter(":checked").length > 0) {
            f.each(K, function() {
                var M = f(this);
                f("#" + M.data("error-message")).removeClass("attention")
            })
        } else {
            if (K.filter(":checked").length === 0 && L.is(":disabled")) {
                J.addClass("attention");
                shared.Forms.Validation.openFormSectionOnError(J)
            }
        }
    }

    function E(T) {
        console.log("shared.Forms: createJsonStringFromDataPasteAttributes()");
        var R = T[0].tagName,
            J = R == "SELECT" ? T.find("option:selected") : T,
            P = T.data("paste-from"),
            Q = T.data("paste-to"),
            M = T.data("paste-target"),
            O = P.split(" "),
            L = Q.split(" "),
            N = M.split(" "),
            K = N.length,
            S = "{";
        f.each(N, function(U) {
            var V = J.prop(O[U]);
            S += '"' + N[U] + '": {"' + L[U] + '": "' + V + '"}';
            if (U < K - 1) {
                S += ","
            }
        });
        S += "}";
        return S
    }

    function H(K, J) {
        console.log("shared.Forms: toggleValidation()");
        if (J == "SELECT") {
            K = K.find("option")
        }
        f.each(K, function() {
            var N = f(this),
                P = N.data("toggle-validation");
            if (typeof P === "undefined") {
                return
            }
            var Q = N.data("toggle-validation").split(" "),
                M, O = false,
                L = [];
            f.each(Q, function(R) {
                if (f.inArray(Q[R], L) < 0 && Q[R]) {
                    L.push(Q[R])
                }
            });
            f.each(L, function(R) {
                if (K.filter('[data-toggle-validation~="' + L[R] + '"]:checked, [data-toggle-validation~="' + L[R] + '"]:selected').length > 0) {
                    O = true
                }
                M = f(".js__toggleValidation-" + L[R]);
                l(M, O)
            })
        })
    }

    function a(N, R, P) {
        console.log("shared.Forms: changeDisabledStateOfFormElements()");
        var L = N.not(":checked, :selected"),
            Q = L.filter("[data-disable]"),
            K = [];
        if (N.filter(":checked, :selected").length !== 0) {
            f.each(Q, function() {
                var T = f(this),
                    S = T.data("disable").split(",");
                f.each(S, function(U) {
                    if (f.inArray(S[U], K) < 0) {
                        K.push(S[U])
                    }
                })
            });
            var J = N.filter(":checked, :selected"),
                O = J.data("disable") ? J.data("disable").split(",") : [""],
                M = [];
            f.each(O, function(S) {
                M.push(f("#" + O[S].trim()))
            });
            f.each(K, function(S) {
                var T = f("#" + K[S].trim());
                if (f.inArray(T, M) < 0) {
                    T.prop("disabled", false).removeClass("disabled")
                }
            });
            if (J.data("disable")) {
                f.each(M, function(T) {
                    var S = M[T];
                    S.prop("disabled", true).addClass("disabled");
                    if (S.is(":checked")) {
                        S.prop("checked", false).removeClass("disabled").trigger("change")
                    }
                })
            }
        }
    }

    function e(K, M) {
        console.log("shared.Forms: getOptionsGroups()");
        var M = typeof M == "undefined" ? false : M,
            J = [],
            L;
        f.each(K, function() {
            var Q = f(this),
                N = this.tagName,
                P = Q.attr("name");
            if (N == "SELECT") {
                L = Q
            } else {
                var O = M ? M : Q.closest("form");
                L = O.find('[name="' + P + '"]')
            }
            if (J.length === 0 || !J[J.length - 1].is(L)) {
                J.push(L)
            }
        });
        return J
    }

    function n(J, L, K) {
        console.log("shared.Forms: submitForm()");
        if (runningXhr.length > 0) {
            shared.Misc.cancelRunningXhrs()
        }
        if (K) {
            u(J)
        }
        if (L.length > 0 && L.hasClass("submit-button")) {
            L.prop("type", "submit");
            J = L.closest("form")
        }
        setTimeout(function() {
            J.submit()
        }, 250)
    }

    function u(J) {
        var N = window.location.href,
            O;
        if (N.indexOf("#") > 0) {
            var K = N.indexOf("#"),
                M = N.substr(K);
            N = decodeURI(N.replace(M, "")).replace(/(<([^>]+)>)/ig, "")
        }
        if (N.indexOf("?") > 0) {
            O = shared.Misc.makeArrayFromParamsList(N.substr(N.indexOf("?") + 1))
        }
        var L = shared.Misc.makeArrayFromParamsList(J.serialize());
        if (O) {
            f.each(O, function(Q) {
                var P = O[Q];
                if (O[P] != "" && jQuery.inArray(P, L) < 0) {
                    J.append('<input name="' + O[Q] + '" type="hidden" value="' + decodeURI(O[P]) + '">')
                }
            })
        }
    }

    function k(J) {
        console.log("shared.Forms: countChars()");
        f.each(J, function() {
            var L = f(this),
                K = L.attr("maxlength") - L.val().length;
            L.closest(".count-chars-container").find(".chars-left").html(K)
        })
    }

    function z(K) {
        console.log("shared.Forms: getNewCaptcha()");
        var J = K.closest(".captcha-image"),
            L = J.find("img"),
            M = '<p class="error">' + local.standardErrorMessage + "</p>";
        J.find(".input-container").append('<div class="loading-captcha">Loading</div>');
        J.addClass("captcha-image--loading");
        J.find(".error").remove();
        f.ajax({
            url: K.attr("href"),
            dataType: "json",
            success: function(N) {
                if (N.length != 0) {
                    L.prop("src", N.src);
                    J.find('input[type="hidden"]').val(N.id);
                    J.find('input[type="text"]').val("");
                    L.on("load", function() {
                        J.find(".loading-captcha").remove().end().removeClass("captcha-image--loading")
                    })
                } else {
                    J.append(M);
                    J.find(".loading-captcha").remove().end().removeClass("captcha-image--loading")
                }
            },
            error: function() {
                J.append(M);
                J.find(".loading-captcha").remove().end().removeClass("captcha-image--loading")
            }
        })
    }

    function p(L) {
        console.log("shared.Forms: setAttributeAtOtherElement()");
        var J = L.data("set-attribute"),
            M = L.data("set-attribute-target"),
            N = L.is(":checked, :selected") ? 1 : 0,
            K = "{";
        K += '"' + M + '": {"' + J + '": ' + N + "}}";
        K = f.parseJSON(K);
        shared.Misc.modifyHtmlElement(K)
    }

    function x(J, K) {
        console.log("shared.Forms: toggleSubmit()");
        var L = J.find('[type="submit"]:eq(0)');
        if (!K || J.find(".error:visible, .validation-explanation:visible, .input-error:visible").length > 0) {
            L.prop("disabled", true).addClass("disabled")
        } else {
            L.prop("disabled", false).removeClass("disabled")
        }
    }

    function D(J) {
        console.log("shared.Forms: trimInputs()");
        f.each(J, function() {
            var K = f(this),
                L = K.val();
            if (L.length > 0) {
                K.val(L.trim())
            }
        })
    }

    function d(J) {
        console.log("shared.Forms: removeHiddenSubmit()");
        J.find('.clicked-button[type="hidden"]').remove()
    }

    function l(J, L) {
        console.log("shared.Forms: changeFormValidationState()");
        var K = J.find("[required]").closest(".input-container").find(".required-marker");
        J.data("validate", L);
        if (!L) {
            shared.Forms.Validation.removeAllErrors(J);
            K.addClass("hidden")
        } else {
            K.removeClass("hidden")
        }
    }

    function G(J) {
        console.log("shared.Forms: focusInput()");
        J.focus().select()
    }

    function C(J) {
        console.log("shared.Forms: selectInput()");
        J.select()
    }

    function h(J, K) {
        console.log("shared.Forms: enableInputs()");
        K.find(".js__enableInputs-container").each(function() {
            var L = f(this);
            if (L.find(".js__enableInputs-item:checked").length > 0) {
                L.find(".disabled-inputs .disabled").attr("disabled", false).removeClass("disabled")
            } else {
                L.find(".disabled-inputs").find("input, select, textarea").attr("disabled", true).addClass("disabled")
            }
        })
    }
    return {
        init: A,
        getOptionsGroups: e,
        submitForm: n,
        toggleSubmit: x,
        focusInput: G,
        selectInput: C,
        trimInputs: D,
        removeHiddenSubmit: d,
        changeFormValidationState: l
    }
}(jQuery));
shared.Forms.Validation = (function(B) {
    function O(Q) {
        var R = Q.find(".js__formValidation");
        if (R.length > 0) {
            x(R);
            K(R)
        }
    }

    function x(Q) {
        console.log("shared.Forms.Validation: addFormValidationListener()");
        B.each(Q, function() {
            var R = B(this),
                S = R.data("disable-submit");
            R.find("[data-regex]").on("blur", function() {
                var U = B(this),
                    T;
                if (h(U)) {
                    T = A(U, true);
                    if (S) {
                        shared.Forms.toggleSubmit(R, T)
                    }
                }
            });
            R.find("[data-allowed-chars]").on("keyup change", function() {
                var U = B(this),
                    T;
                if (h(U)) {
                    T = o(U, true);
                    if (S) {
                        shared.Forms.toggleSubmit(R, T)
                    }
                }
            });
            R.find('input[type="number"]').on("keyup change", function() {
                var U = B(this),
                    T;
                if (h(U) && supportsHtml5InputTypeValidation && (typeof Modernizr == "undefined" || Modernizr.touch)) {
                    T = f(U, true);
                    if (S) {
                        shared.Forms.toggleSubmit(R, T)
                    }
                }
            });
            R.find("[data-max]").on("keyup change", function() {
                var U = B(this),
                    T;
                if (h(U)) {
                    T = d(U, true);
                    if (S) {
                        shared.Forms.toggleSubmit(R, T)
                    }
                }
            });
            R.find("[data-min][data-min-keyup]").on("keyup change", function() {
                var U = B(this),
                    T;
                if (h(U)) {
                    T = k(U, true);
                    if (S) {
                        shared.Forms.toggleSubmit(R, T)
                    }
                }
            });
            R.find("[min]").on("blur", function() {
                var U = B(this),
                    T;
                if (h(U)) {
                    T = c(U, true);
                    if (S) {
                        shared.Forms.toggleSubmit(R, T)
                    }
                }
            });
            R.find("[max]").on("keyup change", function() {
                var U = B(this),
                    T;
                if (h(U)) {
                    T = E(U, true);
                    if (S) {
                        shared.Forms.toggleSubmit(R, T)
                    }
                }
            });
            R.find("[data-trigger-validation]").on("change", function() {
                H(B(this))
            });
            R.find('[type="submit"]').on("click", function(T) {
                T.preventDefault();
                R.data("validation-done", false);
                v(R, B(this))
            });
            R.find(".submit-button").on("click", function(V) {
                V.preventDefault();
                var U = B(this),
                    T = U.closest(".inner-form");
                R.data("validation-done", false);
                T.data("validate", true);
                v(T, U, true)
            })
        })
    }

    function M(Q) {
        console.log("shared.Forms.Validation: addRemoveInitialErrorsListener()");
        Q.on("change.init keyup.init", function() {
            var R = B(this),
                S = R.closest(".fieldset-error").length > 0 ? R.closest(".fieldset-error") : R.closest(".input-container");
            r(R, S)
        })
    }

    function n(Q) {
        console.log("shared.Forms.Validation: addErrorListenerAfterClientSideValidation()");
        Q.find(".form-element[required].input-error").not(".fieldset-validation .form-element[required]").on("change.error keyup.error", function() {
            var R = B(this);
            F(R, R.data("force-tooltip"))
        });
        Q.find(".fieldset-validation .form-element[required].input-error").on("change.error keyup.error", function() {
            p(B(this).closest(".fieldset-validation"))
        });
        Q.find('input[type="checkbox"].input-error').on("change.empty", function() {
            i(B(this))
        });
        Q.find('input[type="radio"].input-error, .input-error input[type="radio"]').on("change.empty", function() {
            j(B(this).closest(".required-radio-group"))
        })
    }

    function H(Q) {
        console.log("shared.Forms.Validation: triggerValidation()");
        B("#" + Q.data("trigger-validation")).trigger("change")
    }

    function r(Q, R) {
        console.log("shared.Forms.Validation: removeInitialErrors()");
        Q.removeClass("input-error");
        R.removeClass("fieldset-error");
        R.find(".error").remove();
        Q.off("change.init")
    }

    function K(R) {
        console.log("shared.Forms.Validation: checkForInitialValidationErrors()");
        var Q = R.find(".form-element.input-error, .fieldset-error .form-element, .error");
        if (Q.length > 0) {
            G(B(Q[0]).closest(".js__formValidation"), true);
            M(Q)
        }
    }

    function z(S, Q, R) {
        console.log("shared.Forms.Validation: showStaticValidationExplanation()");
        if (S.find(".static-error").length > 0) {
            return
        }
        Q.addClass("input-error");
        if (S.find(".validation-explanation--dynamic:not(.hidden)").length < 1) {
            R.removeClass("hidden");
            m(S, R)
        }
    }

    function e(W, T, S) {
        console.log("shared.Forms.Validation: setDynamicValidationExplanation()");
        if (T.length > 0) {
            T.html(S)
        } else {
            var V = [],
                U = shared.Pattern.returnHtml("validationExplanation"),
                R = W.data("explanation-position") || "",
                Q = R != "" ? "validation-explanation--" + R : "";
            V.push(Q);
            V.push(S);
            U = shared.Misc.replacePlaceholderInString(U, V);
            if (W.find('[class^="input-container--"]').length > 0) {
                W = W.find('[class^="input-container--"]:eq(0)')
            }
            W.append(U);
            T = W.find(".validation-explanation--dynamic");
            if (W.find(".validation-explanation--static:not(.hidden)").length > 0) {
                W.find(".validation-explanation--static").addClass("hidden")
            }
        }
        W.find("input").addClass("input-error");
        m(W, T)
    }

    function m(R, Q) {
        console.log("shared.Forms.Validation: setValidationExplanationPosition()");
        if (Q.length > 0 && R.length > 0) {
            if (R.data("explanation-position") == "left") {
                Q.addClass("explanation-position--left")
            }
            Q.css("top", R.find(".form-element").position().top - Q.outerHeight() - 5);
            if (R.data("explanation-position") == "center") {
                Q.css("margin-right", Q.outerWidth() / 2 * -1)
            }
        }
    }

    function u(S, Q, R) {
        console.log("shared.Forms.Validation: hideStaticValidationExplanation()");
        R.addClass("hidden");
        s(S, Q)
    }

    function D(T, R, S, Q) {
        console.log("shared.Forms.Validation: removeDynamicValidationExplanation()");
        S.find('[data-error="' + Q + '"]').remove();
        if (S.find("[data-error]").length == 0) {
            S.remove()
        }
        s(T, R)
    }

    function F(W, U) {
        console.log("shared.Forms.Validation: validateSingleInputs()");
        var Z = W.closest(".input-container"),
            S = "isEmpty",
            X, V = parseInt(W.data("min"), 10),
            Y = parseInt(W.data("max"), 10);
        X = k(W);
        if (X == false) {
            var Q = Z.data("error-position") || "top",
                T, R;
            if (Z.data("error-msg")) {
                T = I(S, Z.data("error-msg"))
            } else {
                if (!isNaN(V) && V > 1) {
                    if (!isNaN(Y) && Y == V) {
                        T = I(S, "needDefiniteAmountOfChars", [V])
                    } else {
                        T = I(S, "minLengthNotReached", [V])
                    }
                } else {
                    T = I(S)
                }
            }
            R = J(Z.find(".error"), S, T);
            if (U) {
                e(Z, Z.find(".error"), R)
            } else {
                t(W, Z, R, Q)
            }
            return false
        }
        N(W, C(Z), S);
        return true
    }

    function k(Q) {
        console.log("shared.Forms.Validation: validateRequiredInputForMinimumValueLength()");
        var R = typeof(Q.data("min")) != "undefined" ? Q.data("min") : 1,
            S = Q.val() ? Q.val() : "";
        if (S.length < R || S == undefined) {
            return false
        }
        return true
    }

    function p(V) {
        console.log("shared.Forms.Validation: validateFieldset()");
        var S = V.find(".form-element[required]"),
            Q = "isEmpty",
            T, U;
        T = L(S);
        if (V.data("error-msg")) {
            U = local[V.data("error-msg")]
        } else {
            U = local.isEmpty
        }
        if (T === false) {
            var R = JSON.parse('{"' + Q + '": "' + U + '"}');
            y(V, R);
            return false
        }
        g(V, Q);
        return true
    }

    function A(R, W) {
        console.log("shared.Forms.Validation: validateInputViaRegEx()");
        var V = R.val(),
            U = R.closest(".input-container"),
            Q = U.find(".error").length > 0 ? U.find(".error") : U.find(".validation-explanation--static"),
            T = b(R, V);
        if (V.length > 0) {
            if (!T) {
                if (W) {
                    z(U, R, Q)
                } else {
                    var S = J(U.find(".error:not(.validation-explanation)"), "regex", U.find(".validation-explanation--static").html());
                    t(R, U, S);
                    U.find(".error:not(.validation-explanation--static)").addClass("static-error")
                }
                R.addClass("input-error");
                return false
            } else {
                if (T) {
                    if (Q.hasClass("validation-explanation--static")) {
                        u(U, R, Q)
                    } else {
                        N(R, U, "regex")
                    }
                    return true
                }
            }
        } else {
            if (U.find(".validation-explanation--static:visible")) {
                u(U, R, U.find(".validation-explanation--static:visible"))
            } else {
                N(R, U, "regex")
            }
            return true
        }
    }

    function b(Q, T) {
        console.log("shared.Forms.Validation: regexTest()");
        var S = new RegExp(Q.data("regex")),
            R = S.test(T);
        return R
    }

    function I(Q, R, T) {
        console.log("shared.Forms.Validation: getErrorMsg()");
        var S;
        if (R && R != "") {
            S = local[R]
        } else {
            S = local[Q]
        }
        if (T) {
            S = shared.Misc.replacePlaceholderInString(S, T)
        }
        return S
    }

    function J(Q, R, T) {
        console.log("shared.Forms.Validation: getErrorHtml()");
        var S = "<ul>";
        if (Q.length > 0 && Q.find('[data-error="' + R + '"]').length === 0) {
            S += Q.find("> ul").html()
        }
        S += '<li data-error="' + R + '">' + T + "</li>";
        S += "</ul>";
        return S
    }

    function o(ab, V) {
        console.log("shared.Forms.Validation: validateInputForAllowedChars()");
        var S = ab.val(),
            aa = ab.closest(".input-container"),
            Y = aa.find(".error");
        if (S.length > 0) {
            var W = new RegExp("[" + ab.data("allowed-chars") + "]+", "g"),
                Z = S.replace(W, ""),
                Q = Z.length,
                U = [];
            if (Q > 0) {
                U.push(Q);
                U.push(Z);
                var X = I("unallowedChars", "unallowedChars", U),
                    R = J(Y, "unallowedChars", X);
                if (V) {
                    e(aa, Y, R)
                } else {
                    t(ab, aa, R)
                }
                return false
            } else {
                T()
            }
        } else {
            T()
        }

        function T() {
            if (Y.hasClass("validation-explanation")) {
                D(aa, ab, Y, "unallowedChars")
            } else {
                N(ab, aa, "unallowedChars")
            }
            return true
        }
    }

    function d(Q, W) {
        console.log("shared.Forms.Validation: validateInputForMaximumValueLength()");
        var R = Q.data("max"),
            V = Q.val(),
            U = Q.closest(".input-container"),
            X = U.find(".validation-explanation--dynamic");
        if (V.length > R) {
            var T = I("maxLength", "maxLengthReached", [Q.data("max")]),
                S = J(U.find(".error"), "maxLength", T);
            if (W) {
                e(U, X, S)
            } else {
                t(Q, U, S)
            }
            return false
        }
        D(U, Q, X, "maxLength");
        return true
    }

    function f(S, W) {
        console.log("shared.Forms.Validation: validateInputTypeNumberForBadInput()");
        var R = S[0].validity.badInput,
            V = S.closest(".input-container"),
            Q = V.find(".error");
        if (R) {
            var U = J(Q, "unallowedChars", local.unallowedCharsMobile);
            if (W) {
                e(V, Q, U)
            } else {
                t(S, V, U)
            }
            return false
        } else {
            T()
        }

        function T() {
            if (Q.hasClass("validation-explanation")) {
                D(V, S, Q, "unallowedChars")
            } else {
                N(S, V, "unallowedChars")
            }
            return true
        }
    }

    function c(Y, T) {
        console.log("shared.Forms.Validation: validateInputForMinimumValue()");
        var V = Y.prop("min"),
            S = parseInt(Y.val(), 10),
            X = Y.closest(".input-container"),
            W = X.find(".validation-explanation--dynamic"),
            Q = X.data("error-position") || "top";
        if (S < V) {
            var U = I("minValue", "minValue", [V]),
                R = J(X.find(".error"), "minValue", U);
            if (T) {
                e(X, W, R)
            } else {
                t(Y, X, R, Q)
            }
            return false
        } else {
            if (W.length > 0) {
                D(X, Y, W, "minValue")
            }
            if (X.find(".error").length > 0) {
                N(Y, C(X), "minValue")
            }
            return true
        }
    }

    function E(Q, W) {
        console.log("shared.Forms.Validation: validateInputForMaximumValue()");
        var T = Q.prop("max"),
            V = parseInt(Q.val(), 10),
            U = Q.closest(".input-container"),
            X = U.find(".validation-explanation--dynamic");
        if (V > T) {
            var S = I("maxValue", "maxValue", [T]),
                R = J(U.find(".error"), "maxValue", S);
            if (W) {
                e(U, X, R)
            } else {
                t(Q, U, R)
            }
            return false
        } else {
            if (X.length > 0) {
                D(U, Q, X, "maxValue")
            }
            if (U.find(".error").length > 0) {
                N(Q, C(U), "maxValue")
            }
            return true
        }
    }

    function L(Q) {
        console.log("shared.Forms.Validation: validateFieldsetInputsForMinimumValueLength()");
        var R = [];
        B.each(Q, function() {
            var T = B(this),
                S = k(T);
            R.push(S)
        });
        if (B.inArray(false, R) >= 0) {
            return false
        } else {
            return true
        }
    }

    function P(Q) {
        console.log("shared.Forms.Validation: validateRequiredDateInputsForMaximumValueLength()");
        var R = [];
        B.each(Q, function() {
            var T = B(this),
                S = T.data("max"),
                U = T.val();
            if (U && U.length > S) {
                R.push(false);
                T.addClass("input-error")
            } else {
                T.removeClass("input-error")
            }
        });
        if (B.inArray(false, R) >= 0) {
            return false
        } else {
            return true
        }
    }

    function j(Y) {
        console.log("shared.Forms.Validation: validateRequiredRadioButtons()");
        var Z = Y.closest(".required-radio-group"),
            V = Z.find('input[type="radio"][required]').attr("name"),
            S = Z.find('input[name="' + V + '"]'),
            U = Z.data("error-msg") ? Z.data("error-msg") : "",
            X = JSON.parse('{"' + U + '": "' + local[U] + '"}'),
            Q = Z.data("error-position") || "top",
            R;
        if (S.filter(":checked").length === 0) {
            R = false
        } else {
            if (S.filter(":checked").is(":hidden")) {
                if (Y.closest(".switch-content:not(.active)").length > 0 || (Y.hasClass("switch-content") && !Y.hasClass("active"))) {
                    R = false
                } else {
                    if (Y.closest(".js__toggleFormSection.closed").length > 0) {
                        R = true
                    }
                }
            } else {
                R = true
            }
        }
        if (!R) {
            if (U.length > 0) {
                var W = I(U, U),
                    T = J(Z.find(".error"), U, W);
                t(S, Z, T, Q)
            } else {
                Y.addClass("input-error")
            }
            return false
        } else {
            N(S, C(Z, Q), U);
            Y.removeClass("input-error");
            return true
        }
    }

    function i(Q) {
        console.log("shared.Forms.Validation: validateRequiredCheckboxes()");
        if (!Q.prop("checked")) {
            Q.addClass("input-error");
            return false
        } else {
            Q.removeClass("input-error");
            return true
        }
    }

    function g(S, R) {
        console.log("shared.Forms.Validation: removeFieldsetErrors()");
        var Q = S.find(".error");
        S.find('[data-error="' + R + '"]').remove();
        if (Q.find("li").length == 0) {
            Q.remove()
        }
        s(S, S.find(".form-element"))
    }

    function q(Q, R) {
        console.log("shared.Forms.Validation: addErrors()");
        B.each(R, function(U, Y) {
            var S = a(Y),
                Z;
            if (S) {
                var X = U;
                B.each(Y, function(ab, ae) {
                    var ad, ac, aa;
                    Z = Q.find('[name="' + X + "[" + ab + ']"]');
                    $container = Z.closest(".fieldset-validation").length > 0 ? Z.closest(".fieldset-validation") : Z.closest(".input-container");
                    B.each(ae, function(af, ag) {
                        aa = af;
                        ac = ag
                    });
                    ad = J($container.find(".error"), aa, ac);
                    t(Z, $container, ad)
                })
            } else {
                var W, V, T;
                Z = Q.find('[name="' + U + '"], [name^="' + U + '["]');
                $container = Z.closest(".fieldset-validation").length > 0 ? Z.closest(".fieldset-validation") : Z.closest(".input-container");
                if ($container.hasClass("fieldset-validation") && Z.length == 1) {
                    Z = $container.find("input")
                }
                B.each(Y, function(aa, ab) {
                    T = aa;
                    V = ab
                });
                W = J($container.find(".error"), T, V);
                t(Z, $container, W)
            }
        });
        G(Q)
    }

    function a(R) {
        console.log("shared.Forms.Validation: checkJsonErrorsForFieldset()");
        var Q;
        B.each(R, function(S, T) {
            if (typeof T == "object") {
                Q = true
            }
        });
        return Q
    }

    function t(S, U, R, Q) {
        console.log("shared.Forms.Validation: addSingleError()");
        var T = C(U, Q);
        if (S.length > 0) {
            S.addClass("input-error")
        }
        if (U.find(".error:not(.validation-explanation--static)").length > 0) {
            U.find(".error").html(R)
        } else {
            if (S.closest(".captcha-image").length > 0) {
                U.find(".form-element:visible").after('<div class="error">' + R + "</div>")
            } else {
                T.append('<div class="error">' + R + "</div>")
            }
        }
        context.Forms.openFormSectionOnError(U)
    }

    function C(S, Q) {
        console.log("shared.Forms.Validation: getErrorMessagePosition()");
        var R;
        if (Q && Q !== "top") {
            if (B("#" + Q).length !== 0) {
                R = B("#" + Q)
            } else {
                R = S
            }
        } else {
            R = S
        }
        return R
    }

    function y(R, S) {
        console.log("shared.Forms.Validation: addFieldsetError()");
        var Q = "";
        R.find(".form-element").addClass("input-error");
        if (R.find(".error").length == 0) {
            R.append('<ul class="error"></ul>')
        }
        B.each(S, function(T, U) {
            if (R.find('.error [data-error="' + T + '"]').length == 0) {
                Q += '<li data-error="' + T + '">' + U + "</li>"
            }
        });
        R.find(".error").append(Q);
        context.Forms.openFormSectionOnError(R)
    }

    function N(S, T, R) {
        console.log("shared.Forms.Validation: removeErrors()");
        var Q = T.find(".error:not(.validation-explanation--static)");
        T.find('[data-error="' + R + '"]').remove();
        if (Q.find("li").length == 0) {
            Q.remove();
            s(T, S)
        }
    }

    function s(S, Q) {
        console.log("shared.Forms.Validation: removeErrorClassIfAllowed()");
        var R = S.find(".validation-explanation");
        if (S.find(".error:visible").length == 0) {
            if (R.length > 0 && !R.hasClass("hidden")) {
                return
            }
            B.each(Q, function() {
                B(this).removeClass("input-error")
            })
        }
    }

    function l(Q) {
        console.log("shared.Forms.Validation: getValidationResults()");
        var T = Q.closest("form").find('select[name*="salutation"]').val() == "FIRMA",
            S = [],
            R = 0;
        B.each(Q.find(".form-element[required]").not(".fieldset-validation .form-element[required]"), function() {
            var V = B(this),
                U = "js__toggleSingleValidation";
            if (h(V) && (!V.hasClass(U) || !T)) {
                S[R] = F(V, V.data("force-tooltip"));
                R++
            }
        });
        B.each(Q.find(".fieldset-validation"), function() {
            var U = B(this);
            if (h(U)) {
                S[R] = p(U);
                R++
            }
        });
        B.each(Q.find("[required][type=checkbox]"), function() {
            var U = B(this);
            if (h(U)) {
                S[R] = i(U);
                R++
            }
        });
        B.each(Q.find(".required-radio-group"), function() {
            var U = B(this);
            if (h(U)) {
                S[R] = j(U);
                R++
            }
        });
        B.each(Q.find("[data-regex]"), function() {
            var U = B(this);
            if (h(U) && U.val().length > 0) {
                S[R] = A(U, U.data("force-tooltip"));
                R++
            }
        });
        B.each(Q.find("[data-allowed-chars]"), function() {
            var U = B(this);
            if (h(U) && U.val().length > 0) {
                S[R] = o(U, U.data("force-tooltip"));
                R++
            }
        });
        B.each(Q.find("[data-max]"), function() {
            var U = B(this);
            if (h(U) && U.val().length > 0) {
                S[R] = d(U, U.data("force-tooltip"));
                R++
            }
        });
        B.each(Q.find("[min]"), function() {
            var U = B(this);
            if (h(U) && U.val().length > 0) {
                S[R] = c(U, U.data("force-tooltip"));
                R++
            }
        });
        B.each(Q.find("[max]"), function() {
            var U = B(this);
            if (h(U) && U.val().length > 0) {
                S[R] = E(U, U.data("force-tooltip"));
                R++
            }
        });
        return S
    }

    function v(R, X, V) {
        console.log("shared.Forms.Validation: validateFormOnSubmit()");
        var T;
        if (!V && R.find(".inner-form[data-validate]").length > 0) {
            R.find(".inner-form[data-validate]").data("validate", false)
        }
        w(R);
        R.find("input, textarea, select").off("change.error keyup.error change.empty keyup.empty");
        shared.Forms.trimInputs(R.find('input[type!="checkbox"], input[type!="radio"], textarea'));
        T = l(R);
        R.data("validation-done", true);
        if (R.hasClass("inner-form")) {
            R.closest("form").data("validation-done", true)
        }
        if (R.data("additional-validation")) {
            if (B.inArray(false, T) < 0) {
                R.data("invalid", false)
            } else {
                R.data("invalid", true)
            }
            var W = 50,
                U = 5000,
                Q = 0;
            (function S() {
                if (R.data("additional-validation-done")) {
                    if (!R.data("prevent-submit")) {
                        if (!R.data("invalid") && !R.data("additional-invalid")) {
                            shared.Forms.submitForm(R, X)
                        } else {
                            if (R.data("invalid") && !R.data("additional-invalid")) {
                                G(R);
                                R.data("additional-validation-done", true);
                                n(R);
                                shared.Forms.removeHiddenSubmit(R)
                            } else {
                                G(R);
                                R.data("additional-validation-done", false);
                                n(R);
                                shared.Forms.removeHiddenSubmit(R)
                            }
                        }
                    }
                } else {
                    if (Q < U) {
                        Q += W;
                        setTimeout(function() {
                            S()
                        }, W)
                    } else {
                        console.log("Timeout!")
                    }
                }
            }())
        } else {
            if (B.inArray(false, T) < 0) {
                R.data("invalid", false);
                R.find(".input-error, .fieldset-error .form-element").removeClass("input-error");
                if (!R.data("prevent-submit") && !R.data("invalid")) {
                    shared.Forms.submitForm(R, X)
                }
            } else {
                n(R);
                R.data("invalid", true);
                G(R);
                shared.Forms.removeHiddenSubmit(R)
            }
        }
    }

    function h(R) {
        console.log("shared.Forms.Validation: checkIfValidationIsRequired()");
        var S = R.closest("[data-validate]"),
            Q = R.parents("[data-validate]"),
            T;
        if (S.length > 0) {
            if (Q.length > 1) {
                if (S.data("validate") === false) {
                    T = false
                } else {
                    T = true;
                    B.each(Q, function() {
                        if (B(this).data("validate") === false) {
                            T = false
                        }
                    })
                }
            } else {
                if (S.data("validate") == true) {
                    if (typeof S.data("validate-trigger") !== "undefined" && B("#" + S.data("validate-trigger")).is(":hidden")) {
                        T = false
                    } else {
                        T = true
                    }
                } else {
                    T = false
                }
            }
        } else {
            T = true
        }
        return T
    }

    function G(aa, V) {
        console.log("shared.Forms.Validation: scrollToFirstError()");
        var X = aa.find(".input-error:visible, .fieldset-error, .error"),
            W = B(X[0]),
            Q = aa.closest(".overlay-container").length > 0 ? true : false,
            Z = Q ? aa.closest(".overlay-container") : B("html, body");
        if (W.length > 0) {
            var U = W.offset().top,
                T = W.closest(".form-section"),
                Y = T.length > 0 ? T.offset().top : 0,
                S, R = V ? 0 : 750;
            if (Q) {
                if (T.length > 0 && U < Y + B(window).height()) {
                    S = Z.scrollTop() + Y - $window.scrollTop()
                } else {
                    S = U - 15
                }
            } else {
                if (T.length > 0 && U < Y + B(window).height()) {
                    S = Y
                } else {
                    S = U - 15
                }
            }
            if (shared.Helper.isInView(W) === false || V) {
                if (B.isFunction(B.fn.animate)) {
                    Z.animate({
                        scrollTop: S
                    }, R)
                } else {
                    setTimeout(function() {
                        window.scrollTo(0, S)
                    }, 10)
                }
            }
        }
    }

    function w(Q) {
        console.log("shared.Forms.Validation: removeAllErrors()");
        Q.find(".input-error, .fieldset-error .form-element").removeClass("input-error");
        Q.find(".error:not(.validation-explanation--static)").remove();
        Q.find(".validation-explanation--static").addClass("hidden")
    }
    return {
        init: O,
        validateInputViaRegEx: A,
        addErrors: q,
        checkIfValidationIsRequired: h,
        addErrorListenerAfterClientSideValidation: n,
        removeAllErrors: w,
        validateRequiredInputForMinimumValueLength: k,
        getValidationResults: l,
        removeErrors: N
    }
}(jQuery));
shared.Helper = (function(a) {
    a.removeItemFromArray = function(b, c) {
        console.log("Helper: removeItemFromArray()");
        b = $.grep(b, function(d) {
            return d != c
        });
        return b
    };
    a.getDomain = function() {
        if (typeof $("html").data("share-domain") != "undefined" && $("html").data("share-domain") != "") {
            return $("html").data("share-domain")
        }
        var b = document.domain.split(".");
        return b[b.length - 2] + "." + b[b.length - 1]
    };
    a.checkIfArraysDiffer = function(d, c) {
        console.log("Helper: checkIfArraysDiffer()");
        return (d < c || c < d)
    };
    a.setCookie = function(b, c) {
        console.log("Helper: setCookie()");
        document.cookie = b + "=" + escape(c) + "; path=/;"
    };
    a.getCookieValue = function(c) {
        console.log("Helper: getCookieValue()");
        var d = document.cookie,
            e = d.indexOf(" " + c + "=");
        if (e == -1) {
            e = d.indexOf(c + "=")
        }
        if (e == -1) {
            d = null
        } else {
            e = d.indexOf("=", e) + 1;
            var b = d.indexOf(";", e);
            if (b == -1) {
                b = d.length
            }
            d = unescape(d.substring(e, b))
        }
        return d
    };
    a.removeCookie = function(b) {
        console.log("Helper: removeCookie()");
        document.cookie = b + "=; expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/;"
    };
    a.isInView = function(d) {
        console.log("shared.Helper: isInView()");
        var c = {
                top: d.offset().top,
                bottom: d.offset().top + d.outerHeight()
            },
            b = {
                top: $window.scrollTop(),
                bottom: $window.scrollTop() + $window.height()
            };
        return c.top >= b.top && c.bottom <= b.bottom
    };
    a.getFileName = function(c) {
        var b;
        if (typeof config.staticFileMapping != "undefined") {
            b = config.staticFileMapping[c]
        } else {
            b = c
        }
        return "/" + b
    };
    a.getCdnUrl = function() {
        if (typeof config.global != "undefined") {
            if (config.global["servers"][0]) {
                return window.location.protocol + "//" + config.global["servers"][0]
            }
        }
        return window.location.origin || (window.location.protocol + "//" + window.location.hostname)
    };
    return a
}(jQuery));
Array.prototype.AllValuesSame = function() {
    var a;
    if (this.length > 0) {
        for (a = 1; a < this.length; a++) {
            if (this[a] !== this[0]) {
                return false
            }
        }
    }
    return true
};
shared.Pattern = (function() {
    var b = {
        validationExplanation: '<div class="validation-explanation validation-explanation--dynamic error %REPLACE%">%REPLACE%</div>',
        systemMessage: '<div class="system-message media"><span class="result-icon result-icon--%REPLACE% media__item media__item--left"></span><div class="system-message__text-container media__content"><div class="system-message__text %REPLACE%"><p>%REPLACE%</p></div></div><span class="clear"></span></div>',
    };

    function a(c) {
        return b[c]
    }
    return {
        returnHtml: a
    }
}());
shared.MediaCenter = (function(c) {
    var j = c(".mediacenter-preview"),
        h = j.find(".main-image"),
        a;

    function k() {
        var l = c(".mediacenter-preview .mediacenter-thumbs .contentslider__area a");
        if (l.length > 0) {
            g(l)
        }
    }

    function g(l) {
        console.log("shared.MediaCenter: addPreviewThumbsListener()");
        l.on("click", function(m) {
            m.preventDefault();
            d(c(this))
        })
    }

    function e() {
        console.log("shared.MediaCenter: cancelImageLoader()");
        c(".mediacenter-thumbs .loading").remove()
    }

    function d(l) {
        console.log("shared.MediaCenter: clickHandlerPreview()");
        var m = l.parents(".contentslider__area").find("li").index(l.parents(".contentslider__area").find(".active")),
            n = l.parents(".contentslider__content").find("li").index(l.parents("li"));
        if (m == n) {
            return
        }
        f(n);
        e()
    }

    function f(n) {
        console.log("shared.MediaCenter: changeMainGalleryImage()");
        a = j.find(".contentslider__content li.active");
        var m = j.find("li:eq(" + n + ")"),
            l = i(m);
        b(l, m)
    }

    function i(n) {
        console.log("shared.MediaCenter: createNewImage()");
        var m = n.find("a").attr("href"),
            o = n.find("a").data("id"),
            q = n.find("a").attr("title"),
            l = n.find("a").data("type"),
            p;
        h.data("type", l).data("id", o);
        p = '<img class="new-image--loading load" src="' + m + '" alt="' + q + '">';
        return p
    }

    function b(l, m) {
        console.log("shared.MediaCenter: addNewImage()");
        var o = setTimeout(function() {
            m.find("a").append('<span class="loading"></span>')
        }, 200);
        h.find(".mediacenter-main-image").append(l);
        var n = h.find(".new-image--loading");
        n.hide().on("load error", function() {
            var p = c(this);
            j.find(".mediacenter-preview__title").html(p.attr("alt"));
            h.find(".mediacenter-main-image img:not(.new-image--loading)").remove();
            p.show().removeClass("new-image--loading");
            clearTimeout(o);
            m.find(".loading").remove();
            a.removeClass("active");
            m.addClass("active")
        })
    }
    return {
        init: k,
        cancelImageLoader: e
    }
}(jQuery));
shared.RequestData = (function(c) {
    var g, s, j, t = "";

    function n(w, x, y, z, v) {
        console.log("shared.RequestData: addSelectListener()");
        x.on("change", function() {
            $select = c(this);
            k(w, $select, x, y, z, v)
        })
    }

    function r(v, w, x) {
        console.log("shared.RequestData: addSortListener()");
        v.on("change", function() {
            if (w.find("option").length > 2) {
                s = q(w);
                b(s, c(this).val());
                h(w, x);
                p(s, w, w, x)
            }
        })
    }

    function q(w) {
        console.log("shared.RequestData: createResultJsonFromOptionsList()");
        var v = w.find("option");
        s = [];
        c.each(v, function() {
            var x = c(this);
            s.push({
                title: x.html(),
                value: x.prop("value"),
                url: x.data("url"),
                image: x.data("image"),
                capacity: x.data("capacity")
            })
        });
        return s
    }

    function m(x, v, w) {
        console.log("shared.RequestData: clearAllData()");
        if (typeof w == "number") {
            v.each(function() {
                var y = c(this);
                if (x.index(y) > w) {
                    u(y)
                }
            })
        } else {
            v.each(function() {
                u(c(this))
            })
        }
    }

    function u(v) {
        console.log("shared.RequestData: clearSelect()");
        v.addClass("disabled").prop("disabled", true);
        v.find("option").each(function() {
            var w = c(this);
            if (w.val() != "") {
                w.remove()
            }
        })
    }

    function h(v, w) {
        console.log("shared.RequestData: clearResultData()");
        v.addClass("disabled").prop("disabled", true);
        v.html(w).trigger("change")
    }

    function p(z, w, x, y) {
        console.log("shared.RequestData: addData()");
        c.each(z, function() {
            w.append('<option value="' + this.value + '" data-capacity="' + this.capacity + '" data-image="' + this.image + '" data-url="' + this.url + '" title="' + this.title + '">' + this.title + "</option>")
        });
        var v;
        if (z.length == 1) {
            w.find("option:eq(1)").prop("selected", true);
            v = true
        }
        w.prop("disabled", false).removeClass("disabled");
        if (w.is(x)) {
            y.detach();
            w.find("option:eq(0)").prop("selected", true);
            w.trigger("change").focus();
            if (x.closest(".hidden").length > 0) {
                x.closest(".hidden").removeClass("hidden")
            }
        }
        if (v) {
            w.trigger("change")
        }
    }

    function k(A, v, B, E, x, z) {
        console.log("shared.RequestData: searchByList()");
        var D = B.index(v),
            F = B.index(B.filter(":not(.disabled)").last()),
            y, C = f(A, v);
        if (v.val() == "" || D < F) {
            m(B, B, D);
            if (!E.hasClass("disabled")) {
                h(E, x)
            }
        }
        if (v.val() != "") {
            var w = v.data("next");
            url = d(A, w, z, B);
            i(A, v, url, y, C, E)
        }
    }

    function e(w) {
        console.log("shared.RequestData: storeSelectedValues()");
        var v = [];
        w.each(function() {
            var x = c(this);
            v[x.attr("name")] = x.val()
        });
        return v
    }

    function f(y, w) {
        console.log("shared.RequestData: getNextSelect()");
        var v;
        if (w.data("next")) {
            v = y.find('select[name*="' + w.data("next") + '"]')
        } else {
            var x = y.find("select").index(w) + 1;
            v = y.find("select:eq(" + x + ")")
        }
        return v
    }

    function l() {
        console.log("shared.RequestData: cancelOldXhr()");
        g.abort()
    }

    function a(y, w) {
        console.log("shared.RequestData: addLoadingIndicator()");
        c(".loading.current").removeClass("current");
        var A = y.parent(),
            x = '<span class="loading current loading--small loading--red loading--requestdata xhr-loading"></span>',
            v = y.parents(".numbered-list");
        if (v.length > 0) {
            y.parents(".numbered-list__item").find(".nr").addClass("loading current loading--small loading--red")
        } else {
            if (A[0].tagName == "LABEL" || A.hasClass("input-bg")) {
                A.append(x)
            } else {
                if (typeof louis != "undefined") {
                    y.prev("label").append(x)
                } else {
                    x = '<span class="xhr-select-loading loading loading--small loading--red"></span>';
                    y.before(x)
                }
            }
        }
        var z = setTimeout(function() {
            t = w.html();
            var B = 0;
            j = setInterval(function() {
                if (B == 0) {
                    w.html(local.loading)
                } else {
                    w.html(w.html() + ".")
                }
                B++;
                if (B == 4) {
                    B = 0
                }
            }, 350)
        }, 0)
    }

    function o(v, x, y) {
        console.log("shared.RequestData: clearLoadingIndicator()");
        var w = x ? x.parents(".numbered-list") : "";
        if (y) {
            y.html(t)
        }
        if (j) {
            clearInterval(j)
        }
        if (w && w.length > 0) {
            if (w.find(".nr.loading").length > 1) {
                c.each(w.find(".nr.loading:not(.current)"), function() {
                    this.className = "nr"
                })
            } else {
                w.find(".nr.loading")[0].className = "nr"
            }
        } else {
            if (v.find(".loading--requestdata").length > 1) {
                v.find(".loading--requestdata:not(.current)").remove()
            } else {
                if (v.find(".xhr-select-loading").length > 0) {
                    v.find(".xhr-select-loading").remove()
                } else {
                    v.find(".loading--requestdata").remove()
                }
            }
        }
    }

    function d(y, w, v, x) {
        console.log("shared.RequestData: createRequestUrl()");
        url = v + "?";
        x.each(function() {
            var z = c(this);
            if (z.val() != "") {
                url += this.name + "=" + this.value + "&"
            }
        });
        if (w == "bikes" && y.find(".bike-selection-sortby:checked").length > 0) {
            url += "sortby=" + y.find(".bike-selection-sortby:checked").val() + "&"
        }
        url += "get=" + w;
        return url
    }

    function i(B, y, w, v, x, z) {
        console.log("shared.RequestData: getData()");
        var A = x.find("option:eq(0)");
        if (g && g.readystate != 4) {
            l()
        }
        if (x.is(z)) {
            h(z, A)
        }
        a(y, A);
        g = c.ajax({
            url: w,
            success: function(E, C, F) {
                var D = F.getResponseHeader("content-type") || "";
                if (E.pageReload) {
                    location.reload();
                    return
                }
                s = E.options;
                if (D.indexOf("html") > -1) {
                    s = JSON.parse(s)
                }
                if (s && s.length != 0) {
                    if (B.parents(".article__order-container").length > 0) {
                        shared.RequestData.ArticleDetail.addData(B, s, x, v)
                    } else {
                        p(s, x, z, A)
                    }
                    if (B.find(".info-box-error.active").length > 0) {
                        B.find(".info-box-error.active").remove()
                    }
                }
                if (B.find(".error").length > 0) {
                    B.find(".error").fadeOut()
                }
            },
            error: function() {
                $error = '<p class="error">' + local.standardErrorMessage + "</p>";
                B.find("legend").after($error)
            },
            complete: function() {
                o(B, y, A)
            }
        })
    }

    function b(v, w) {
        console.log("shared.RequestData: sortData()");

        function x(y) {
            return function(A, z) {
                var C = A[y] != "" ? A[y] : 0,
                    B = z[y] != "" ? z[y] : 0;
                if (y == "capacity" || y == "distance") {
                    C = parseFloat(C);
                    B = parseFloat(B)
                }
                if (C > B) {
                    return 1
                }
                if (C < B) {
                    return -1
                }
                return 0
            }
        }
        return v.sort(x(w))
    }
    return {
        addSelectListener: n,
        addSortListener: r,
        clearAllData: m,
        clearResultData: h,
        addData: p,
        storeSelectedValues: e,
        getNextSelect: f,
        addLoadingIndicator: a,
        clearLoadingIndicator: o,
        createRequestUrl: d,
        getData: i,
        sortData: b
    }
}(jQuery));
shared.RequestData.Standard = (function() {
    function a(c) {
        var d = c.find('select[data-type="data"]'),
            f = c.find('select[name*="bikes"]'),
            g = f.find("option:first"),
            e = c.find(".bike-selection-sortby"),
            b = c.data("select-from-list-url") ? c.data("select-from-list-url") : c.closest("[data-select-from-list-url]").data("select-from-list-url");
        shared.RequestData.addSelectListener(c, d, f, g, b);
        shared.RequestData.addSortListener(e, f, g)
    }
    return {
        init: a
    }
}());
shared.RequestData.ArticleDetail = (function(c) {
    function i(o) {
        var l = o.find("form"),
            n = l.find(".article__variant-selection select"),
            k = l.data("url"),
            m = o.find(".js__increaseAmount"),
            p = o.find(".js__decreaseAmount");
        if (m.length > 0) {
            e(m)
        }
        if (p.length > 0) {
            g(p)
        }
        j(l, n, k);
        f(n)
    }

    function j(l, m, k) {
        console.log("shared.RequestData.ArticleDetail: addSelectListener()");
        m.on("change", function() {
            $select = c(this);
            var n = false;
            if ($select.parents("[data-trigger-selects]").length > 0) {
                n = true
            }
            h(l, $select, m, k, n)
        })
    }

    function e(k) {
        k.on("click", function() {
            if (parseInt(c("#article__order-qty").val()) && (parseInt(c("#article__order-qty").val()) + 1) <= 999) {
                c("#article__order-qty").val(parseInt(c("#article__order-qty").val()) + 1)
            }
        })
    }

    function g(k) {
        k.on("click", function() {
            if (parseInt(c("#article__order-qty").val()) && (parseInt(c("#article__order-qty").val()) - 1) >= 1) {
                c("#article__order-qty").val(parseInt(c("#article__order-qty").val()) - 1)
            }
        })
    }

    function f(l) {
        console.log("shared.RequestData.ArticleDetail: checkForSelectedValuesInBrowserCache()");
        var m = l.filter(":not(:disabled)"),
            k = c(m[m.length - 1]);
        if (shared.ArticleDetail.testForInitialSelectedVariant() === false && k.val() != "") {
            k.trigger("change")
        }
    }

    function d(m, k) {
        console.log("shared.RequestData.ArticleDetail: getData()");
        var n = m.find('[type="submit"]'),
            l;
        m.find(".article__variant-container").addClass("load");
        n.prop("disabled", true).addClass("disabled");
        l = m.find(".article__variant").html();
        c.ajax({
            url: k,
            success: function(q, o, s) {
                var p = s.getResponseHeader("content-type") || "",
                    r = q;
                if (p.indexOf("html") > -1) {
                    r = JSON.parse(r)
                }
                if (r.pageReload) {
                    location.reload();
                    return
                }
                m.find(".article__variant").html(r.html);
                m.find(".article__variant-container").removeClass("load");
                if (typeof context.ArticleDetail.reformatArticleVariant !== "undefined") {
                    context.ArticleDetail.reformatArticleVariant()
                }
                shared.Misc.init(m.find(".article__variant"));
                context.Misc.init(m.find(".article__variant"));
                shared.Forms.changeFormValidationState(m.find(".article__variant-selection"), false);
                shared.ArticleDetail.changeMediaCenterImageAccordingToVariant();
                n.prop("disabled", false).removeClass("disabled");
                if (r.replaceForAjaxCalls != undefined) {
                    shared.Misc.replaceForAjaxCalls(r.replaceForAjaxCalls)
                }
                if (r.modifyHtmlElement != undefined) {
                    shared.Misc.modifyHtmlElement(r.modifyHtmlElement)
                }
            },
            error: function() {
                if (m.find(".error").length == 0) {
                    $error = '<p class="error">' + local.standardErrorMessage + "</p>";
                    m.find(".article__variant-selection").append($error)
                }
            }
        })
    }

    function b(o, n, m, k) {
        console.log("shared.RequestData.ArticleDetail: addData()");
        c.each(n, function() {
            m.append('<option value="' + this.value + '">' + this.title + "</option>")
        });
        var l;
        if (null != k && k != "") {
            l = a(k, m)
        } else {
            if (n.length == 1) {
                m.find("option:eq(1)").prop("selected", true);
                l = true
            }
        }
        m.prop("disabled", false).removeClass("disabled");
        if (m.attr("name") == "variant" || m.attr("name") == "bike-assoc") {
            if (n.length == 1) {
                m.closest("div").addClass("hidden");
                m.trigger("change")
            } else {
                m.closest("div").removeClass("hidden")
            }
        }
        if (m.val() == "") {
            context.ArticleDetail.restoreDefaultData()
        }
        if (l) {
            m.trigger("change")
        }
    }

    function h(p, k, q, n, o) {
        console.log("shared.RequestData.ArticleDetail: searchByList()");
        var r = q.index(k),
            m, s = shared.RequestData.getNextSelect(p, k);
        if (s.val() == "" || s.val() === null || typeof s.val() == "undefined") {
            o = false
        }
        if (p.is('form[name="bike-selection-article"]') && c(".article__variant-availability.active").length != 0) {
            context.ArticleDetail.restoreDefaultData()
        }
        if (o) {
            m = shared.RequestData.storeSelectedValues(q)
        }
        shared.RequestData.clearAllData(q, q, r);
        if (k.val() != "") {
            var l = null != s.attr("name") ? s.attr("name") : k.data("next");
            url = shared.RequestData.createRequestUrl(p, l, n, q);
            if (k.data("next") == "variant-html") {
                d(p, url)
            } else {
                shared.RequestData.getData(p, k, url, m, s)
            }
        }
    }

    function a(l, m) {
        console.log("shared.RequestData.ArticleDetail: restoreValue()");
        var k = l[m.attr("name")];
        m.find("option").filter(function() {
            var n = c(this);
            if (n.val() == k) {
                k = "";
                return n
            }
        }).prop("selected", true);
        if (typeof data !== "undefined" && data.length == 1 && (m.attr("name") == "variant" || m.attr("name") == "bike-assoc")) {
            m.find("option:eq(1)").attr("selected", true)
        }
        return startTrigger = true
    }
    return {
        init: i,
        addData: b
    }
}(jQuery));
shared.AutoSuggest = (function(c) {
    var g, h;

    function i(j) {
        g = c(".header-search-container");
        d(j)
    }

    function d(l) {
        console.log("shared.AutoSuggest: addGetResultsListener()");
        var j, m, k = l.closest("form").data("url");
        l.on("change keyup", function() {
            var n = c(this),
                o = n.val();
            clearTimeout(m);
            m = setTimeout(function() {
                if (f(o, j)) {
                    h = context.AutoSuggest.getResults(o, k)
                } else {
                    if (o.length < 2) {
                        a()
                    }
                }
                j = o
            }, 200)
        })
    }

    function f(k, j) {
        if (k.length > 1 && k != j) {
            return true
        }
        return false
    }

    function b(l, m, j) {
        var k = "";
        c.each(l, function(n, o) {
            k += '<li class="results__category"><ul>';
            c.each(o.results, function(q, p) {
                k += '<li class="header-search__result"><a class="result__link ' + j + '" href="' + p.url + '"><span class="result__title">';
                if (o.alias == "in-category") {
                    if (typeof louis != "undefined") {
                        k += '<span class="result__query">' + m + '</span> in <span class="result__rubric">' + p.title + "</span> (" + p.amount + " " + local.autoSuggest_treffer + ")"
                    } else {
                        k += '<span class="result__query">' + m + '</span> in <span class="result__rubric">' + p.title + "</span> (" + p.amount + ")"
                    }
                } else {
                    k += e(m, p.title)
                }
                k += "</span>";
                k += '<span class="result__category">';
                if (o.alias == "article") {
                    k += local["autoSuggest_" + o.alias] + "<br>" + local.autoSuggest_in + " " + p.category["title"]
                } else {
                    if (o.alias == "sitemap") {
                        k += local.autoSuggest_auf + " " + c("html").data("share-domain")
                    } else {
                        k += local["autoSuggest_" + o.alias]
                    }
                }
                k += "</span></a></li>"
            });
            k += "</ul></li>"
        });
        if (k != "") {
            h = context.AutoSuggest.appendResults(g, k)
        } else {
            a()
        }
    }

    function e(l, j) {
        var m = new RegExp(l, "gi"),
            k = j.replace(m, function(n) {
                return '<span class="result__query">' + n + "</span>"
            });
        return k
    }

    function a() {
        if (typeof h != "undefined") {
            h.remove()
        }
        if (typeof louis != "undefined") {
            if (typeof h != "undefined") {
                louis.AutoSuggest.removeMouseOverListener(h)
            }
            louis.AutoSuggest.removeKeyboardListener()
        }
    }
    return {
        init: i,
        buildResultsList: b,
        removeResults: a
    }
}(jQuery));
shared.Service = (function(c) {
    function d(e) {
        var f = c(".js__bikeNotFound");
        if (f.length > 0) {
            b(f)
        }
    }

    function b(e) {
        console.log("Service: addBikeNotFoundListener()");
        if (e.prop("checked") == true) {
            c(".bike-select-by-registration").show()
        }
        e.click(function(f) {
            var g = e.prop("checked") ? true : false;
            a(c(".bike-select-by-registration"), g)
        })
    }

    function a(e, f) {
        if (f) {
            e.show();
            c("#bike-selection-manufacturer").removeAttr("required");
            c("#bike-selection-biketype").removeAttr("required");
            c("#bike-selection-capacity").removeAttr("required");
            c("#registration-manufacturer-short").attr("required", "required");
            c("#registration-capacity").attr("required", "required");
            c("#registration-sale-designation").attr("required", "required");
            c("#registration-identification-number").attr("required", "required");
            c("#registration-first-registration").attr("required", "required")
        } else {
            e.hide();
            c("#bike-selection-manufacturer").attr("required", "required");
            c("#bike-selection-biketype").attr("required", "required");
            c("#bike-selection-capacity").attr("required", "required");
            c("#registration-manufacturer-short").removeAttr("required");
            c("#registration-capacity").removeAttr("required");
            c("#registration-sale-designation").removeAttr("required");
            c("#registration-identification-number").removeAttr("required");
            c("#registration-first-registration").removeAttr("required")
        }
    }
    return {
        init: d
    }
}(jQuery));
