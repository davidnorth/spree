/**
This is a collection of javascript functions and whatnot
under the spree namespace that do stuff we find helpful.
Hopefully, this will evolve into a propper class.
**/

var spree;
if (!spree) spree = {};

jQuery.noConflict() ;

jQuery(document).ajaxStart(function(){
  jQuery("#progress").slideDown();
});

jQuery(document).ajaxStop(function(){
  jQuery("#progress").slideUp();
});

jQuery.fn.visible = function(cond) { this[cond ? 'show' : 'hide' ]() };

// Apply to individual radio button that makes another element visible when checked
jQuery.fn.radioControlsVisibilityOfElement = function(dependentElementSelector){
  if(!this.get(0)){ return  }
  showValue = this.get(0).value;
  radioGroup = $("input[name='" + this.get(0).name + "']");
  radioGroup.each(function(){
    jQuery(this).click(function(){
      jQuery(dependentElementSelector).visible(this.checked && this.value == showValue)
    });
    if(this.checked){ this.click() }
  });
}

jQuery.fn.ajaxForm = function(){
  this.submit(function(){
    //$('#' + $(this).attr("target") + '_spinner').show();
    jQuery.post(jQuery(this).attr("action"), jQuery(this).serialize(), null, "script")
    return false;
  })
}

var request = function(options) {
  jQuery.ajax(jQuery.extend({ url : options.url, type : 'get' }, options));
  return false;
};
 
// remote links handler
jQuery('a[data-remote=true]').live('click', function() {
  alert('remote link');
  if(method = jQuery(this).attr("data-method")){
    return request({ url: this.href, type: 'POST', data: {'_method': method} });
  } else {
    return request({ url: this.href });
  }
});
 
// remote forms handler
jQuery('form[data-remote=true]').live('submit', function() {
  return request({ url : this.action, type : this.method, data : jQuery(this).serialize() });
});


//$('.ajax_delete_link').unbind('click').click(function(){
//  if(confirm('Are you sure?')){
//    $('#'+$(this).attr("target")+'_spinner').show();
//    $.post(this.href, {'_method': 'delete'}, null, 'script');
//  }
//  return false;
//})



