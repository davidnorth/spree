jQuery(document).ready(function() {
  
  jQuery('.products_rule_products_source_field input').click(function() {

    $rule_container = jQuery(this).parents('.promotion-rule');
    
    if(this.checked && this.value == 'manual'){

      $rule_container.find('.products_rule_products').show();
      $rule_container.find('.products_rule_product_group').hide();
      
    } else {

      $rule_container.find('.products_rule_products').hide();
      $rule_container.find('.products_rule_product_group').show();
      
    }
    
    
    
  });
  
});

