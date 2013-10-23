<script type="text/javascript">
jQuery(document).ready(function () {
  <#if Static["com.osafe.util.Util"].isProductStoreParmTrue(request,"QUICKLOOK_ACTIVE")>
    <#if QUICKLOOK_DELAY_MS?has_content && Static["com.osafe.util.Util"].isNumber(QUICKLOOK_DELAY_MS) && QUICKLOOK_DELAY_MS != "0">
      jQuery("div.js_eCommerceThumbNailHolder").hover(function(){jQuery(this).find("div.js_plpQuicklook").fadeIn(${QUICKLOOK_DELAY_MS});},function () {jQuery(this).find("div.js_plpQuicklook").fadeOut(${QUICKLOOK_DELAY_MS});});
    <#else>
      jQuery("div.js_eCommerceThumbNailHolder div.js_plpQuicklook").show();
    </#if>
  </#if>

    jQuery('.js_facetValue.js_hideThem').hide();
    jQuery('.js_facetValue.js_showAllOfThem').hide();
    jQuery('.js_seeLessLink').hide();
    jQuery('.js_showAllLink').hide();

    jQuery('.js_plpFeatureSwatchImage').click(function() {
        var swatchVariant = jQuery(this).next('.js_swatchVariant').clone();

        var swatchVariantOnlinePrice = jQuery(this).nextAll('.js_swatchVariantOnlinePrice:first').clone().show();
        swatchVariantOnlinePrice.removeClass('js_swatchVariantOnlinePrice').addClass('js_plpPriceOnline');
        
        jQuery(this).parents('.productItem').find('.js_plpPriceOnline').replaceWith(swatchVariantOnlinePrice);

        var swatchVariantListPrice = jQuery(this).nextAll('.js_swatchVariantListPrice:first').clone().show();
        swatchVariantListPrice.removeClass('js_swatchVariantListPrice').addClass('js_plpPriceList');
        jQuery(this).parents('.productItem').find('.js_plpPriceList').replaceWith(swatchVariantListPrice);
        
        var swatchVariantSaveMoney = jQuery(this).nextAll('.js_swatchVariantSaveMoney:first').clone().show();
        swatchVariantSaveMoney.removeClass('js_swatchVariantSaveMoney').addClass('js_plpPriceSavingMoney');
        jQuery(this).parents('.productItem').find('.js_plpPriceSavingMoney').replaceWith(swatchVariantSaveMoney);
        
        var swatchVariantSavingPercent = jQuery(this).nextAll('.js_swatchVariantSavingPercent:first').clone().show();
        swatchVariantSavingPercent.removeClass('js_swatchVariantSavingPercent').addClass('js_plpPriceSavingPercent');
        jQuery(this).parents('.productItem').find('.js_plpPriceSavingPercent').replaceWith(swatchVariantSavingPercent);
        
        jQuery(this).parents('.productItem').find('.js_eCommerceThumbNailHolder').find('.js_swatchProduct').replaceWith(swatchVariant);
        jQuery('.js_eCommerceThumbNailHolder').find('.js_swatchVariant').show().attr("class", "js_swatchProduct");
        jQuery(this).siblings('.js_plpFeatureSwatchImage').removeClass("js_selected");
        jQuery(this).addClass("js_selected");
        makePDPUrl(this);
        
        <#if PLP_FACET_GROUP_VARIANT_MATCH?has_content>
          var descFeatureGroup = jQuery(this).prev("input.js_featureGroup").val();
          if(descFeatureGroup != '') {
            jQuery.each( jQuery('.'+descFeatureGroup), function(idx, elm){
              changeSwatchImg(elm);
            });
          }
          
          var title = jQuery(this).attr("title");
          jQuery.each( jQuery('.'+title), function(idx, elm){
            changeSwatchImg(elm);
          });
        </#if>
    });

    jQuery('.js_seeMoreLink').click(function() {
        jQuery(this).hide().parents('li').siblings('li.js_hideThem').show();
        //show js_showAllLink if number of items to show is greater than sys param FACET_VALUE_MAX
        //jQuery(this).siblings('.showAllLink').show();
        
        if(jQuery(this).siblings('.js_showAllLink').length > 0)
        {
        	jQuery(this).siblings('.js_showAllLink').show();
        }
        else
        {
        	jQuery(this).siblings('.js_seeLessLink').show();
        }
    });
    
    jQuery('.js_showAllLink').click(function() {
        jQuery(this).hide().parents('li').siblings('li.js_hideThem').show();
        //show showAll li
        jQuery(this).hide().parents('li').siblings('li.js_showAllOfThem').show();
        jQuery(this).siblings('.js_seeLessLink').show();
        //hide js_showAllLink if number of items to show is greater than sys param FACET_VALUE_MAX
        jQuery(this).siblings('.js_showAllLink').hide();
    });

    jQuery('.js_seeLessLink').click(function() {
        jQuery(this).hide().parents('li').siblings('li.js_hideThem').hide();
        //if showAll, then also hide showAll li
        jQuery(this).hide().parents('li').siblings('li.js_showAllOfThem').hide();
        jQuery(this).siblings('.js_seeMoreLink').show();
    });
    
    jQuery('.js_showHideFacetGroupLink').click(function() 
    {
        jQuery(this).toggleClass("js_seeMoreFacetGroupLink");
        jQuery(this).toggleClass("js_seeLessFacetGroupLink");
        
        jQuery(this).siblings('ul').find('li.js_hideThem').slideToggle();
        jQuery(this).siblings('ul').find('li.js_showAllOfThem').hide();
        //check if js_seeLessLink is currently displayed. If so, hide everything
        var seeLessLink = jQuery(this).siblings('ul').find('li').find('.js_seeLessLink');
        var seeMoreLink = jQuery(this).siblings('ul').find('li').find('.js_seeMoreLink');
        if(jQuery(seeLessLink).css('display') != 'none')
        {
        	jQuery(seeLessLink).hide();
        	jQuery(this).siblings('ul').find('li').find('.js_showAllLink').hide();
        	
        }
        else if(jQuery(seeMoreLink).css('display') != 'none')
        {
        	jQuery(seeMoreLink).hide();
        	jQuery(this).siblings('ul').find('li').find('.js_showAllLink').hide();
        	jQuery(this).siblings('ul').find('li.js_hideThem').hide();
        	
        }
        else
        {
        
	        if(jQuery(this).siblings('ul').find('li').find('.js_showAllLink').length > 0)
	        {
	        	jQuery(this).siblings('ul').find('li').find('.js_showAllLink').slideToggle();
	        	jQuery(seeMoreLink).hide();
	        }
	        else
	        {
	        	jQuery(this).siblings('ul').find('li').find('.js_seeLessLink').slideToggle();
	        	jQuery(seeMoreLink).hide();
	        }
        
        }
        
    });
    
    function changeSwatchImg(elm) {
        var swatchVariant = jQuery(elm).next('.js_swatchVariant').clone();
        var swatchVariantOnlinePrice = jQuery(elm).nextAll('.js_swatchVariantOnlinePrice:first').clone().show();
        swatchVariantOnlinePrice.removeClass('js_swatchVariantOnlinePrice').addClass('js_plpPriceOnline');
        jQuery(elm).parents('.productItem').find('.js_plpPriceOnline').replaceWith(swatchVariantOnlinePrice);

        var swatchVariantListPrice = jQuery(elm).nextAll('.js_swatchVariantListPrice:first').clone().show();
        swatchVariantListPrice.removeClass('js_swatchVariantListPrice').addClass('js_plpPriceList');
        jQuery(elm).parents('.productItem').find('.js_plpPriceList').replaceWith(swatchVariantListPrice);
        
        var swatchVariantSaveMoney = jQuery(elm).nextAll('.js_swatchVariantSaveMoney:first').clone().show();
        swatchVariantSaveMoney.removeClass('js_swatchVariantSaveMoney').addClass('js_plpPriceSavingMoney');
        jQuery(elm).parents('.productItem').find('.js_plpPriceSavingMoney').replaceWith(swatchVariantSaveMoney);
        
        var swatchVariantSavingPercent = jQuery(elm).nextAll('.js_swatchVariantSavingPercent:first').clone().show();
        swatchVariantSavingPercent.removeClass('js_swatchVariantSavingPercent').addClass('js_plpPriceSavingPercent');
        jQuery(elm).parents('.productItem').find('.js_plpPriceSavingPercent').replaceWith(swatchVariantSavingPercent);
        
        jQuery(elm).parents('.productItem').find('.js_eCommerceThumbNailHolder').find('.js_swatchProduct').replaceWith(swatchVariant);
        jQuery('.js_eCommerceThumbNailHolder').find('.js_swatchVariant').show().attr("class", "js_swatchProduct");
        jQuery(elm).siblings('.js_plpFeatureSwatchImage').removeClass("js_selected");
        jQuery(elm).addClass("js_selected");
        makePDPUrl(elm);
    }
    
    function makePDPUrl(elm) {
        var plpFeatureSwatchImageId = jQuery(elm).attr("id");
        var plpFeatureSwatchImageIdArr = plpFeatureSwatchImageId.split("|");
        var pdpUrlId = plpFeatureSwatchImageIdArr[1]+plpFeatureSwatchImageIdArr[0]; 
        var pdpUrl = document.getElementById(pdpUrlId).value;
        
        var productFeatureType = plpFeatureSwatchImageIdArr[0];
        
        jQuery('#'+plpFeatureSwatchImageIdArr[1]+'_productFeatureType').val(productFeatureType); 
        jQuery(elm).parents('.productItem').find('a.pdpUrl').attr("href",pdpUrl);
        jQuery(elm).parents('.productItem').find('a.pdpUrl.review').attr("href",pdpUrl+"#productReviews");
    }
});




</script>