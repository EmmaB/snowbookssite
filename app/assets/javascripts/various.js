$(document).ready(function() {



 // $("input").live("blur", function() {
 //   return $(this).parents("form").submit();
 // });
 //
 // $("text_area").live("blur", function() {
 //   return $(this).parents("form").submit();
 // });


  $('.carousel').carousel()
  $(".collapse").collapse()
  $('.dropdown-toggle').dropdown()
  $('#bs-docs-sidenav').scrollspy()
  $('[rel=tooltip]').tooltip({
    delay: { show: 50, hide: 100 },
    container: 'body'
    })
  $('[rel=popover-true]').popover({
    placement: 'bottom'
    });

  $('[rel=popover-true-top]').popover({
    placement: 'top'
    });

  $('[rel=popover-true-right]').popover({
    placement: 'right'
    });

$('#myModal').modal({
  backdrop: 'static',
  show:     false
});

$('#navig').liteAccordion({
  autoPlay : false,
  pauseOnHover : true,
  theme : 'light',
  rounded : true,
  enumerateSlides : false,
  containerHeight :110,
  activateOn: 'click',
  rounded :true,
  linkable :true
  });


  $(".triggerx1").click(function(){
      $(".panelx1").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });
  $(".triggerx2").click(function(){
      $(".panelx2").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });
  $(".triggerx3").click(function(){
      $(".panelx3").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });
  $(".triggerx4").click(function(){
      $(".panelx4").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });
  $(".triggerx5").click(function(){
      $(".panelx5").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });
  $(".triggerx6").click(function(){
      $(".panelx6").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });
  $(".triggerx7").click(function(){
      $(".panelx7").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });
  $(".triggerx8").click(function(){
      $(".panelx8").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });
  $(".triggerx9").click(function(){
      $(".panelx9").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });
  $(".triggerx10").click(function(){
      $(".panelx10").toggle("fast");
      $(this).toggleClass("active");
      return false;
  });

});

// http://jqueryui.com/sortable/#connect-lists
$(document).ready

$(function() {
  $( "#sortable1, #sortable2" ).sortable({
    connectWith: ".connectedSortable"
  }).disableSelection();
});



  /* http://railscasts.com/episodes/147-sortable-lists-revised?view=asciicast, but in normal jquery, not coffee script */
  $(document).ready
  (function() {
    return $('#schedules').sortable({
      axis: 'y',
      handle: '.handle',
      update: function() {
        return $.post($(this).data('update-url'), $(this).sortable('serialize'));
      }
    });
  });

  $(document).ready
  (function() {
    return $('#contracttemplates').sortable({
      axis: 'y',
      handle: '.handle',
      update: function() {
        return $.post($(this).data('update-url'), $(this).sortable('serialize'));
      }
    });
  });


  $(document).ready
  (function() {
    return $('#works').sortable({
      axis: 'y',
      handle: '.handle',
      update: function() {
        return $.post($(this).data('update-url'), $(this).sortable('serialize'));
      }
    });
  });

  $(document).ready
  (function() {
    return $('#periods').sortable({
      axis: 'y',
      handle: '.handle',
      update: function() {
        return $.post($(this).data('update-url'), $(this).sortable('serialize'));
      }
    });
  });

    // for the extents conditional drop down
    $(document).ready(function(){

        $(".nested_drop_down_two_of_two").each(function(i,v){
            $(this).attr("data-content",$(this).html());
        });
        $(".nested_drop_down_one_of_two").live("change", function() {

            selected_type = $(this).find("option:selected").text();
            var content = $($(this).parent("li.select").next().find(".nested_drop_down_two_of_two").attr("data-content")).filter("[label='"+selected_type+"']").html()
            $(this).parent("li").next().find(".nested_drop_down_two_of_two").html(content);
            return true;
        });
    });


    $(document).ready(function() {
    current_page = document.location.href
    proposal_status = window.proposal

    if (current_page.match(/(com|3000|.co.uk)\/rightsindex/)) {
    $.setFragment({ "nav" : '7'})

    } else if (current_page.match(/(com|3000|.co.uk)\/print_costing/)) {
    $.setFragment({ "nav" : '4'})

    } else if (current_page.match(/(com|3000|.co.uk)\/book_collection/)) {
    $.setFragment({ "nav" : '11'})

    } else if (current_page.match(/(com|3000|.co.uk)\/book_rights/)) {
    $.setFragment({ "nav" : '7'})

    } else if (current_page.match(/(com|3000|.co.uk)\/book/) && proposal_status == "rights")   {
    $.setFragment({ "nav" : '7'})

    } else if (current_page.match(/(com|3000|.co.uk)\/book/) && proposal_status == "non_book")   {
    $.setFragment({ "nav" : '16'})

    } else if (current_page.match(/(com|3000|.co.uk)\/work/) && proposal_status == "non_book")   {
    $.setFragment({ "nav" : '16'})

    } else if (current_page.match(/(com|3000|.co.uk)\/work/) && proposal_status != undefined)  {
    $.setFragment({ "nav" : '13'})

    } else if (current_page.match(/(com|3000|.co.uk)\/book/) && proposal_status != undefined)   {
    $.setFragment({ "nav" : '13'})

    } else if (current_page.match(/(com|3000|.co.uk)\/print/) && proposal_status != undefined) {
    $.setFragment({ "nav" : '13'})

    } else if (current_page.match(/(com|3000|.co.uk)\/proposal/)) {
    $.setFragment({ "nav" : '13'})

    } else if (current_page.match(/(com|3000|.co.uk)\/estimate_templates/)) {
    $.setFragment({ "nav" : '13'})

    } else if (current_page.match(/(com|3000|.co.uk)\/rightsreportindex/)) {
    $.setFragment({ "nav" : '7'})

    } else if (current_page.match(/(com|3000|.co.uk)\/profitindex/)) {
    $.setFragment({ "nav" : '9'})

    } else if (current_page.match(/(com|3000|.co.uk)\/work/)) {
    $.setFragment({ "nav" : '1'})


    } else if (current_page.match(/(com|3000|.co.uk)\/book/)) {
    $.setFragment({ "nav" : '2'})

    } else if (current_page.match(/(com|3000|.co.uk)\/importedition/)) {
    $.setFragment({ "nav" : '2'})

    } else if (current_page.match(/(com|3000|.co.uk)\/xmlimport/)) {
    $.setFragment({ "nav" : '2'})

    } else if (current_page.match(/(com|3000|.co.uk)\/imprint/)) {
    $.setFragment({ "nav" : '2'})

    } else if (current_page.match(/(com|3000|.co.uk)\/contactform/)) {
    $.setFragment({ "nav" : '0'})

    } else if (current_page.match(/(com|3000|.co.uk)\/contact/)) {
    $.setFragment({ "nav" : '3'})

    } else if (current_page.match(/(com|3000|.co.uk)\/sales/)) {
    $.setFragment({ "nav" : '4'})

    } else if (current_page.match(/(com|3000|.co.uk)\/return/)) {
    $.setFragment({ "nav" : '4'})

    } else if (current_page.match(/(com|3000|.co.uk)\/purchases/)) {
    $.setFragment({ "nav" : '5'})

    } else if (current_page.match(/(com|3000|.co.uk)\/print/)) {
    $.setFragment({ "nav" : '12'})

    } else if (current_page.match(/(com|3000|.co.uk)\/amazontitles/)) {
    $.setFragment({ "nav" : '9'})

    } else if (current_page.match(/(com|3000|.co.uk)\/profitarchives/)) {
    $.setFragment({ "nav" : '9'})

    } else if (current_page.match(/(com|3000|.co.uk)\/reports/)) {
    $.setFragment({ "nav" : '9'})


    } else if (current_page.match(/(com|3000|.co.uk)\/onixarchives/)) {
    $.setFragment({ "nav" : '9'})

    } else if (current_page.match(/(com|3000|.co.uk)\/contract/)) {
    $.setFragment({ "nav" : '6'})

    } else if (current_page.match(/(com|3000|.co.uk)\/clause/)) {
    $.setFragment({ "nav" : '6'})

    } else if (current_page.match(/(com|3000|.co.uk)\/advance/)) {
    $.setFragment({ "nav" : '8'})

    } else if (current_page.match(/(com|3000|.co.uk)\/importadvance/)) {
    $.setFragment({ "nav" : '8'})

    } else if (current_page.match(/(com|3000|.co.uk)\/payments/)) {
    $.setFragment({ "nav" : '8'})

    } else if (current_page.match(/(com|3000|.co.uk)\/importpayment/)) {
    $.setFragment({ "nav" : '8'})

    } else if (current_page.match(/(com|3000|.co.uk)\/rights/)) {
    $.setFragment({ "nav" : '7'})

    } else if (current_page.match(/(com|3000|.co.uk)\/foreignright_update/)) {
    $.setFragment({ "nav" : '7'})

    } else if (current_page.match(/(com|3000|.co.uk)\/foreignright/)) {
    $.setFragment({ "nav" : '7'})

    } else if (current_page.match(/(com|3000|.co.uk)\/rightrules/)) {
    $.setFragment({ "nav" : '7'})

    } else if (current_page.match(/(com|3000|.co.uk)\/channels/)) {
    $.setFragment({ "nav" : '11'})

    } else if (current_page.match(/(com|3000|.co.uk)\/periods/)) {
    $.setFragment({ "nav" : '11'})

    } else if (current_page.match(/(com|3000|.co.uk)\/royarchives/)) {
    $.setFragment({ "nav" : '8'})

    } else if (current_page.match(/(com|3000|.co.uk)\/royalty_/)) {
    $.setFragment({ "nav" : '8'})

    } else if (current_page.match(/(com|3000|.co.uk)\/roystatements/)) {
    $.setFragment({ "nav" : '8'})

    } else if (current_page.match(/(com|3000|.co.uk)\/rules/)) {
    $.setFragment({ "nav" : '8'})

    } else if (current_page.match(/(com|3000|.co.uk)\/importsalecsvs/)) {
    $.setFragment({ "nav" : '4'})

    } else if (current_page.match(/(com|3000|.co.uk)\/csv/)) {
    $.setFragment({ "nav" : '11'})

    } else if (current_page.match(/(com|3000|.co.uk)\/companies/)) {
    $.setFragment({ "nav" : '11'})

    } else if (current_page.match(/(com|3000|.co.uk)\/currencies/)) {
    $.setFragment({ "nav" : '11'})

    } else if (current_page.match(/(com|3000|.co.uk)\/schedules/)) {
    $.setFragment({ "nav" : '15'})

    } else if (current_page.match(/(com|3000|.co.uk)\/tasks/)) {
    $.setFragment({ "nav" : '15'})

    } else if (current_page.match(/(com|3000|.co.uk)\/task_roles/)) {
    $.setFragment({ "nav" : '15'})


    } else if (current_page.match(/(com|3000|.co.uk)\/rightlists/)) {
    $.setFragment({ "nav" : '11'})
    } else if (current_page.match(/(com|3000|.co.uk)\/users/)) {
    $.setFragment({ "nav" : '11'})
    } else if (current_page.match(/(com|3000|.co.uk)\/finance_code/)) {
    $.setFragment({ "nav" : '11'})


    } else if (current_page.match(/(com|3000|.co.uk)\/isbnlists/)) {
    $.setFragment({ "nav" : '11'})

    } else if (current_page.match(/(com|3000|.co.uk)\/posts/)) {
    $.setFragment({ "nav" : '10'})

    } else if (current_page.match(/(com|3000|.co.uk)\/catalogue/)) {
    $.setFragment({ "nav" : '10'})

    } else if (current_page.match(/(com|3000|.co.uk)\/impressions/)) {
    $.setFragment({ "nav" : '12'})

  } else if (current_page.match(/(com|3000|.co.uk)\/dam/)) {
  $.setFragment({ "nav" : '14'})
  } else if (current_page.match(/(com|3000|.co.uk)\/marketing/)) {
  $.setFragment({ "nav" : '10'})

  } else if (current_page.match(/(com|3000|.co.uk)\/ai_/)) {
  $.setFragment({ "nav" : '10'})


  } else if (current_page.match(/(com|3000|.co.uk)\/expectedsale/)) {
  $.setFragment({ "nav" : '11'})
} else if (current_page.match(/(com|3000|.co.uk)\/non_book/)) {
$.setFragment({ "nav" : '16'})


    } else { // set home as active
    $.setFragment({ "nav" : '0'})

    };

    });

$(document).ready(function() {
    function remove_fields(link) {
        $(link).previous("input[type=hidden]").value = "1";
        $(link).up(".nested-fields").hide();
    }

    function add_fields(link, association, content) {
        var new_id = new Date().getTime();
        var regexp = new RegExp("new_" + association, "g")
        $(link).up().insert({
            before: content.replace(regexp, new_id)
        });
    }
});

$(document).ready(function() {
  /* Activating Best In Place */
  $(".best_in_place").best_in_place();
});

$(document).ready(function() {
    // hides the slickbox as soon as the DOM is ready
    $('#slickbox').hide();
    // toggles the slickbox on clicking the noted link
    $('#slick-toggle').click(function() {
        $('#slickbox').toggle(400);
        return false;
    });
});


$(document).ready(function() {
    $('div.swoosh > div').hide();
    $('div.swoosh > h6').click(function() {
        $(this).next().toggle(400);
    });
});


$(document).ready(function() {
    $('#checkAllAuto').click(
        function() {
            $("INPUT[type='checkbox']").attr('checked', $('#checkAllAuto').is(':checked'));
        }
    )
});


$(document).ready
    (function() {
      $('.datePicker').datepicker({
        dateFormat: 'dd/mm/yy'
      });
    });


    $(document).ready(function() {
      /* Activating Best In Place */
      jQuery(".best_in_place").best_in_place();
    });

/// this adds to Modernizr's functionality. Says what to do if details not supported by the current browser. From here: http://akral.bitbucket.org/details-tag/
$(document).ready(function() {

(function(b){var d="open"in document.createElement("details"),e;b.fn.details=function(c){"open"==c&&(d?this.prop("open",!0):this.trigger("open"));"close"==c&&(d?this.prop("open",!1):this.trigger("close"));"init"==c&&e(b(this));if(!c)return d?this.open:this.hasClass("open")};e=function(c){c.filter(".animated").each(function(){var a=b(this),c=a.children("summary").remove();a.html("<div class=details-wrapper>"+a.html()+"</div>").prepend(c)}).on("open.details",function(){var a=b(this),c=a.children(".details-wrapper");
c.hide();setTimeout(function(){c.slideDown(a.data("animation-speed"))},0)}).on("close.details",function(){var a=b(this),c=a.children(".details-wrapper");setTimeout(function(){a.prop("open",!0).addClass("open");c.slideUp(a.data("animation-speed"),function(){a.prop("open",!1).removeClass("open")})},0)});if(d)b("body").on("click","summary",function(){var a=b(this).parent();a.prop("open")?a.trigger("close"):a.trigger("open")});else b("html").addClass("no-details"),b("head").prepend('<style>details{display:block}summary{cursor:pointer}details>summary::before{content:"\u25ba"}details.open>summary::before{content:"\u25bc"}details:not(.open)>:not(summary){display:none}</style>'),
c.on("open.details",function(){b(this).addClass("open").trigger("change.details")}).on("close.details",function(){b(this).removeClass("open").trigger("change.details")}).on("toggle.details",function(){var a=b(this);a.hasClass("open")?a.trigger("close"):a.trigger("open")}).each(function(){var a=b(this);a.children("summary").length||a.prepend("<summary>Details</summary>")}).children("summary").click(function(){b(this).parent().trigger("toggle")}).filter(":not(tabindex)").attr("tabindex",0).end().keyup(function(a){(32==
a.keyCode||13==a.keyCode&&!b.browser.opera)&&b(this).parent().trigger("toggle")}).end().contents(":not(summary)").filter(function(){return 3===this.nodeType&&/[^\t\n\r ]/.test(this.data)}).wrap("<span>").end().end().filter(":not([open])").prop("open",!1).end().filter("[open]").addClass("open").prop("open",!0).end(),b.browser.msie&&9>b.browser.msie&&c.on("open.details",function(){b(this).children().not("summary").show()}).on("close.details",function(){b(this).children().not("summary").hide()}).filter(":not(.open)").children().not("summary").hide()};
e(b("details"))})(jQuery);
});

