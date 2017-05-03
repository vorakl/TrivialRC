/* =============================================================
 * bootstrap-collapse.js v2.3.2
 * http://twitter.github.com/bootstrap/javascript.html#collapse
 * =============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */
!function(t){"use strict"
var e=function(e,s){this.$element=t(e),this.options=t.extend({},t.fn.collapse.defaults,s),this.options.parent&&(this.$parent=t(this.options.parent)),this.options.toggle&&this.toggle()}
e.prototype={constructor:e,dimension:function(){var t=this.$element.hasClass("width")
return t?"width":"height"},show:function(){var e,s,n,i
if(!this.transitioning&&!this.$element.hasClass("in")){if(e=this.dimension(),s=t.camelCase(["scroll",e].join("-")),n=this.$parent&&this.$parent.find("> .accordion-group > .in"),n&&n.length){if(i=n.data("collapse"),i&&i.transitioning)return
n.collapse("hide"),i||n.data("collapse",null)}this.$element[e](0),this.transition("addClass",t.Event("show"),"shown"),t.support.transition&&this.$element[e](this.$element[0][s])}},hide:function(){var e
!this.transitioning&&this.$element.hasClass("in")&&(e=this.dimension(),this.reset(this.$element[e]()),this.transition("removeClass",t.Event("hide"),"hidden"),this.$element[e](0))},reset:function(t){var e=this.dimension()
return this.$element.removeClass("collapse")[e](t||"auto")[0].offsetWidth,this.$element[null!==t?"addClass":"removeClass"]("collapse"),this},transition:function(e,s,n){var i=this,a=function(){"show"==s.type&&i.reset(),i.transitioning=0,i.$element.trigger(n)}
this.$element.trigger(s),s.isDefaultPrevented()||(this.transitioning=1,this.$element[e]("in"),t.support.transition&&this.$element.hasClass("collapse")?this.$element.one(t.support.transition.end,a):a())},toggle:function(){this[this.$element.hasClass("in")?"hide":"show"]()}}
var s=t.fn.collapse
t.fn.collapse=function(s){return this.each(function(){var n=t(this),i=n.data("collapse"),a=t.extend({},t.fn.collapse.defaults,n.data(),"object"==typeof s&&s)
i||n.data("collapse",i=new e(this,a)),"string"==typeof s&&i[s]()})},t.fn.collapse.defaults={toggle:!0},t.fn.collapse.Constructor=e,t.fn.collapse.noConflict=function(){return t.fn.collapse=s,this},t(document).on("click.collapse.data-api","[data-toggle=collapse]",function(e){var s,n=t(this),i=n.attr("data-target")||e.preventDefault()||(s=n.attr("href"))&&s.replace(/.*(?=#[^\s]+$)/,""),a=t(i).data("collapse")?"toggle":n.data()
n[t(i).hasClass("in")?"addClass":"removeClass"]("collapsed"),t(i).collapse(a)})}(window.jQuery)
