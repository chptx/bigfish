<script language="JavaScript" type="text/javascript">
  <#if currentProduct?exists>
  <#assign PDP_QTY_MIN = Static["com.osafe.util.Util"].getProductStoreParm(request,"PDP_QTY_MIN")!"1"/>
  <#assign PDP_QTY_MAX = Static["com.osafe.util.Util"].getProductStoreParm(request,"PDP_QTY_MAX")!"99"/>
  function sortReviews() 
  {
      document.addform.sortReviewBy.value=document.getElementById('js_reviewSort').value;
      var reviewParams = jQuery('.js_pdpReviewList').find('input.reviewParam').serialize();
      jQuery.get('<@ofbizUrl>sortPdpReview?'+reviewParams+'&rnd='+String((new Date()).getTime()).replace(/\D/gi, "")+'</@ofbizUrl>', function(data) 
      {
          var sortedList = jQuery(data).find('.js_pdpReviewList');
          jQuery('.js_pdpReviewList').replaceWith(sortedList);
      });
  }

  jQuery(document).ready(function()
  {
    jQuery('.js_pdpFeatureSwatchImage').click(function() 
    {
        if (jQuery('.js_seeItemDetail').length) 
        {
            jQuery('#js_plpQuicklook_Container .js_seeItemDetail').attr('href', jQuery('#quicklook_Url_'+this.title).val());
        }
    }); 
  
    jQuery('.js_pdpUrl.js_review').click(function() 
    {
        var tabAnchor = jQuery('#js_productReviews').parents('.ui-tabs-panel').attr('id');
        jQuery.find('a[href="#'+tabAnchor+'"]').each(function(elm)
        {
            jQuery(elm).click();
        });
    });

    jQuery('#js_reviewSort').change(function() 
    {
        var tabAnchor = jQuery('#js_productReviews').parents('.ui-tabs-panel').attr('id');
        jQuery.find('a[href="#'+tabAnchor+'"]').each(function(elm)
        {
            jQuery(elm).click();
        });
     });
     
    jQuery('.js_plpFeatureSwatchImage').click(function() 
    {
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
        jQuery(this).siblings('.js_plpFeatureSwatchImage').removeClass('js_selected');
        jQuery(this).addClass('js_selected');
        makeProductUrl(this);
    });
    
    activateInitialZoom();

    var selectedSwatch = '${StringUtil.wrapString(parameters.productFeatureType)!""}';
    if(selectedSwatch != '') 
    {
        var featureArray = selectedSwatch.split(":");
        //jQuery('.pdpRecentlyViewed .'+featureArray[1]).click();
        //jQuery('.pdpComplement .'+featureArray[1]).click();
    }
    
  });
    var detailImageUrl = null;
    function setAddProductId(name) 
    {
        document.addform.add_product_id.value = name;
        if (document.addform.quantity == null) return;
    }
    function setProductStock(name) 
    {
        var elm = document.getElementById("js_addToCart");
        if(VARSTOCK[name]=="outOfStock")
        {
            elm.setAttribute("onClick","javascript:void(0)");
            jQuery('#js_addToCart').addClass("inactiveAddToCart");
        } 
        else 
        {
            jQuery('#js_addToCart').removeClass("inactiveAddToCart");
            elm.setAttribute("onClick","javascript:addItem('addToCart')");
        }
        var elm = document.getElementById("js_addToWishlist");
        if (elm !=null )
        {
            elm.setAttribute("onClick","javascript:addItem('addToWishlist')");
            jQuery('#js_addToWishlist').removeClass("inactiveAddToWishlist");
        }
    }
    
    function addItem(id) 
    {
       if (document.addform.add_product_id.value == 'NULL' || document.addform.add_product_id.value == '') 
       {
           for (i = 0; i < OPT.length; i++) 
           {
            var optionName = OPT[i];
            var indexSelected = document.forms["addform"].elements[optionName].selectedIndex;
            if(indexSelected <= 0)
            {
                // Trim the FT prefix and convert to title case
                var properName = OPT[i].substr(2);
                // capitalize comes from prototype, do capitalize to each part
                var parts = properName.split('_');
                parts.each(function(element,index){
                    parts[index] = element.capitalize();
                });
                properName = parts.join(" ");
                alert("Please select a " + properName);
                break;
            }
           }
           return;
       } 
       else 
       {
       	   //if qauntity div is displayed then get the input value, else use default value of 1
       	   
           if(jQuery('form[name=addform] input[name="quantity"]').length)
           {
           		var quantity = Number(jQuery('form[name=addform] input[name="quantity"]').val());
           }
           else
           {
           		var quantity = Number(1);
           }
           var add_product_id = jQuery('form[name=addform] input[name="add_product_id"]').val();
           var qtyInCart = Number(0);
           if(jQuery('#js_qtyInCart_'+add_product_id).length)
           {
               var qtyInCart = Number(jQuery('#js_qtyInCart_'+add_product_id).val());
           }

           var lowerLimit = Number(${PDP_QTY_MIN!});
           var upperLimit = Number(${PDP_QTY_MAX!});
           if(quantity < lowerLimit)
           {
                alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMinQtyError,'\"','\\"'))}");
                return false;
           }
           if(upperLimit!= 0 && ((quantity + qtyInCart) > upperLimit))
           {
                alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMaxQtyError,'\"','\\"'))}");
                return false;
           }
           if(!isWhole(quantity))
           {
                alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPQtyDecimalNumberError,'\"','\\"'))}");
                return false;
           }
           if (id == "addToCart")
           {
               // add to cart action
    		   recurrenceIsChecked = jQuery('#js_pdpPriceRecurrenceCB').is(":checked");
	    	   if(recurrenceIsChecked)
	    	   {
                  document.addform.action="<@ofbizUrl>${addToCartRecurrenceAction!""}</@ofbizUrl>";
               }
               else
               {
                  document.addform.action="<@ofbizUrl>${addToCartAction!""}</@ofbizUrl>";
               }
               document.addform.submit();
           }
           else if (id == "addToWishlist")
           {
               // add to wish list action
               document.addform.action="<@ofbizUrl>${addToWishListAction!""}</@ofbizUrl>";
               document.addform.submit();
           }
       }
    }
    
    
    
    var isWhole_re = /^\s*\d+\s*$/;
    function isWhole (s) 
    {
        return String(s).search (isWhole_re) != -1
    } 	
 
    function replaceDetailImage(largeImageUrl, detailImageUrl) 
    {
        if (!jQuery('#mainImages').length) 
        {
            var mainImages = jQuery('#js_mainImageDiv').clone();
            jQuery(mainImages).find('img.js_productLargeImage').attr('id', 'js_mainImage');
            jQuery('#js_productDetailsImageContainer').html(mainImages.html());
            jQuery('#js_seeMainImage a').attr("href", "javascript:replaceDetailImage('"+largeImageUrl+"', '"+detailImageUrl+"');");
        }
        <#assign activeZoom = Static["com.osafe.util.Util"].isProductStoreParmTrue(request,"PDP_IMG_ZOOM_ACTIVE_FLAG")/>
        <#if activeZoom>
            var mainImages = jQuery('#js_mainImageDiv').clone();
            jQuery(mainImages).find('img.js_productLargeImage').attr('id', 'js_mainImage');
            jQuery(mainImages).find('img.js_productLargeImage').attr('src', largeImageUrl+ "?" + new Date().getTime());
            jQuery(mainImages).find('a').attr('class', 'innerZoom');
            if(detailImageUrl != "") 
            {
              jQuery(mainImages).find('a').attr('href', detailImageUrl);
            } 
            else 
            {
                jQuery(mainImages).find('a').attr('href', 'javaScript:void(0);');
            }
            jQuery('#js_productDetailsImageContainer').html(mainImages.html());
            activateZoom(detailImageUrl);
            
        </#if>
        if (document.images['js_mainImage'] != null) 
        {
            var detailimagePath;
            document.getElementById("js_mainImage").setAttribute("src",largeImageUrl);
            if(document.getElementById('js_largeImage')) 
            {
                setDetailImage(detailImageUrl);
            }
            <#assign IMG_SIZE_PDP_REG_W = Static["com.osafe.util.Util"].getProductStoreParm(request,"IMG_SIZE_PDP_REG_W")!""/>
            document.getElementById("js_mainImage").setAttribute("class","js_productLargeImage<#if !IMG_SIZE_PDP_REG_W?has_content> productLargeImageDefaultWidth</#if>");
            detailimagePath = "javascript:displayDialogBox('largeImage_')";
            if (jQuery('#js_mainImageLink').length) 
            {
                jQuery('#js_mainImageLink').attr("href",detailimagePath);
            }
        }
    }

    function setDetailImage(detailImageUrl) 
    {
        if (typeof detailImageUrl == "undefined" || detailImageUrl == "NULL" || detailImageUrl == "") 
        {
            return;
        }
        var image = new Image();
        image.src = detailImageUrl+ "?" + new Date().getTime();
        image.onerror = function () {
          jQuery('#js_largeImage').attr('src', '/osafe_theme/images/user_content/images/NotFoundImagePDPDetail.jpg');
      };
      image.onload = function () 
      {
          jQuery('#js_largeImage').attr('src', detailImageUrl);
      };
    }
    
    function findIndex(name) 
    {
        for (i = 0; i < OPT.length; i++) 
        {
            if (OPT[i] == name) 
            {
                return i;
            }
        }
        return -1;
    }
    var firstNoSelection = "false";
    function getList(name, index, src) 
    {
    	var noSelection = "false";
        currentFeatureIndex = findIndex(name);
        if(firstNoSelection == "true")
        {
        	noSelection ="true";
        }
        if(index != -1)
        {
        	var liElm = jQuery('#Li'+name+" li").get(index);
		}
		else
		{
			var liElm = jQuery('#Li'+name+" li").get(0);
			noSelection ="true";
		}
        jQuery(liElm).siblings("li").removeClass("js_selected");
        jQuery(liElm).addClass("js_selected");
        
        // set the drop down index for swatch selection
        document.forms["addform"].elements[name].selectedIndex = (index*1)+1;
        if (currentFeatureIndex < (OPT.length-1)) 
        {
		    
            // eval the next list if there are more
            var selectedValue = document.forms["addform"].elements[name].options[(index*1)+1].value;
            var selectedText = document.forms["addform"].elements[name].options[(index*1)+1].text;
            
            var mapKey = name+'_'+selectedText;
            var featureGroupDesc = VARGROUPMAP[VARMAP[mapKey]];

            jQuery('.js_pdpRecentlyViewed .'+featureGroupDesc).click();
            jQuery('.js_pdpComplement .'+featureGroupDesc).click();
            jQuery('.js_pdpAccessory .'+featureGroupDesc).click();
            
            jQuery('.js_pdpRecentlyViewed .'+selectedText).click();
            jQuery('.js_pdpComplement .'+selectedText).click();
            jQuery('.js_pdpAccessory .'+selectedText).click();
            
            var detailImgUrl = '';
            if(VARMAP[mapKey]) 
            {
                if(jQuery('#js_mainImage_'+VARMAP[mapKey]).length) 
                { 
                    var variantMainImages = jQuery('#js_mainImage_'+VARMAP[mapKey]).clone();
                    //jQuery(variantMainImages).find('img').each(function(){jQuery(this).attr('src', jQuery(this).attr('title')+ "?" + new Date().getTime());})
                    jQuery(variantMainImages).find('a').attr('class', 'innerZoom');
                    detailImgUrl = jQuery(variantMainImages).find('a').attr('href');
                    jQuery('#js_productDetailsImageContainer').html(variantMainImages.html());
                }
                    var variantAltImages = jQuery('#js_altImage_'+VARMAP[mapKey]).clone();
                    //jQuery(variantAltImages).find('img').each(function(){ jQuery(this).attr('src', jQuery(this).attr('title')+ "?" + new Date().getTime());})
                    jQuery('#js_eCommerceProductAddImage').html(variantAltImages.html());

                    var variantSeeMainImages = jQuery('#js_seeMainImage_'+VARMAP[mapKey]).clone();
                    jQuery('#js_seeMainImage').html(variantSeeMainImages.html());
                    
                    var variantProductVideo = jQuery('#js_productVideo_'+VARMAP[mapKey]).html();
                    jQuery('#js_productVideo').html(variantProductVideo);
                    
                    var variantProductVideoLink = jQuery('#js_productVideoLink_'+VARMAP[mapKey]).html();
                    jQuery('#js_productVideoLink').html(variantProductVideoLink);
                    
                    var variantProductVideo360 = jQuery('#js_productVideo360_'+VARMAP[mapKey]).html();
                    jQuery('#js_productVideo360').html(variantProductVideo360);
                    
                    var variantProductVideo360Link = jQuery('#js_productVideo360Link_'+VARMAP[mapKey]).html();
                    jQuery('#js_productVideo360Link').html(variantProductVideo360Link);
                    
                    var variantPdpPriceSavingMoney = jQuery('#js_pdpPriceSavingMoney_'+VARMAP[mapKey]).html();
                    jQuery('#js_pdpPriceSavingMoney').html(variantPdpPriceSavingMoney);
                    
                    var variantPdpPriceSavingPercent = jQuery('#js_pdpPriceSavingPercent_'+VARMAP[mapKey]).html();
                    jQuery('#js_pdpPriceSavingPercent').html(variantPdpPriceSavingPercent);
                    
                    var variantPdpPriceList = jQuery('#js_pdpPriceList_'+VARMAP[mapKey]).html();
                    jQuery('#js_pdpPriceList').html(variantPdpPriceList);
                    
                    var variantPdpPriceOnLine = jQuery('#js_pdpPriceOnLine_'+VARMAP[mapKey]).html();
                    jQuery('#js_pdpPriceOnLine').html(variantPdpPriceOnLine);
                    
                    var variantPdpVolumePricing = jQuery('#js_pdpVolumePricing_'+VARMAP[mapKey]).html();
                    jQuery('#js_pdpVolumePricing').html(variantPdpVolumePricing);              
                    
                    var variantLargeImages = jQuery('#js_largeImageUrl_'+VARMAP[mapKey]).clone();
            		var variantPdpLongDescription = jQuery('#js_pdpLongDescription_Virtual').html();
            		var variantPdpDistinguishingFeature = jQuery('#js_pdpDistinguishingFeature_Virtual').html();
            	
            		jQuery(variantLargeImages).find('.js_mainImageLink').attr('id', 'js_mainImageLink');
            		jQuery('#js_seeLargerImage').html(variantLargeImages.html());
            		jQuery('#js_pdpLongDescription').html(variantPdpLongDescription);
            		jQuery('#js_pdpDistinguishingFeature').html(variantPdpDistinguishingFeature);
                    
            }
            if (index == -1) 
            {
               for (i = currentFeatureIndex; i < OPT.length; i++) 
               {
                   var featureName = jQuery('.js_selectableFeature_'+(i+1)).attr("name");
               
                   if(i == 0)
                   {
                       <#if featureOrderFirst?has_content>
                           var Variable1 = eval("list${featureOrderFirst}()");
                           jQuery('#js_addToCart').addClass("inactiveAddToCart");
	                       jQuery('#js_addToWishlist').addClass("inactiveAddToWishlist");
                       </#if>
                   }
                   else
                   {    
                       
	                   if(i == currentFeatureIndex)
	                   {
	                       var Variable1 = eval("list" + featureName + jQuery('.js_selectableFeature_'+i).val() + "()");
	                       var Variable1 = eval("listLi" + featureName + jQuery('.js_selectableFeature_'+i).val() + "()");
	                       jQuery('.js_selectableFeature_'+(i+1)).children().removeAttr("disabled"); 
	                   }
	                   else
	                   {
	                       var Variable1 = eval("list" + featureName + "()");
	                       var Variable1 = eval("listLi" + featureName + "()");
	                   }
                   }
               } 
              
              
              firstNoSelection = "true";
				
			  var variantLargeImages = jQuery('#js_largeImageUrl_Virtual').clone();
              var variantPdpLongDescription = jQuery('#js_pdpLongDescription_Virtual').html();
              var variantPdpDistinguishingFeature = jQuery('#js_pdpDistinguishingFeature_Virtual').html();
            	
              jQuery(variantLargeImages).find('.js_mainImageLink').attr('id', 'js_mainImageLink');
              jQuery('#js_seeLargerImage').html(variantLargeImages.html());
              jQuery('#js_pdpLongDescription').html(variantPdpLongDescription);
              jQuery('#js_pdpDistinguishingFeature').html(variantPdpDistinguishingFeature);
				
            } 
            else 
            {
                firstNoSelection = "false";
                var Variable1 = eval("list" + OPT[(currentFeatureIndex+1)] + selectedValue + "()");
                var Variable2 = eval("listLi" + OPT[(currentFeatureIndex+1)] + selectedValue + "()");
                  
                  var elm = document.getElementById("js_addToCart");
                  elm.setAttribute("onClick","javascript:addItem('addToCart')");
                  var elm = document.getElementById("js_addToWishlist");
                  if (elm !=null )
                  {
                    elm.setAttribute("onClick","javascript:addItem('addToWishlist')");
                  }
                  if (currentFeatureIndex+1 <= (OPT.length-1) ) 
                  {
	                    var nextFeatureLength = document.forms["addform"].elements[OPT[(currentFeatureIndex+1)]].length;
	                    if(nextFeatureLength == 2) 
	                    {
	                      getList(OPT[(currentFeatureIndex+1)],'0',1);
	                      jQuery('#js_addToCart').removeClass("inactiveAddToCart");
	                      if (elm !=null )
	                      {
	                          jQuery('#js_addToWishlist').removeClass("inactiveAddToWishlist");
	                      }
	                      return;
	                    } 
	                    else 
	                    {
	                      jQuery('#js_addToCart').addClass("inactiveAddToCart");
	                      if (elm !=null )
	                      {
	                          jQuery('#js_addToWishlist').addClass("inactiveAddToWishlist");
	                      }
	                    }
                  }
                   
            }
            // set the product ID to NULL to trigger the alerts
            setAddProductId('NULL');

        }
        else 
        {
            
			// this is the final selection -- locate the selected index of the last selection
            var indexSelected = document.forms["addform"].elements[name].selectedIndex;
            // using the selected index locate the sku
            var sku = document.forms["addform"].elements[name].options[indexSelected].value;
            // set the product ID
            if(firstNoSelection == "false")
            {
            	setAddProductId(sku);
            }
            else
            {
            	setAddProductId("");
            }
            
            var varProductId = jQuery('#js_add_product_id').val();
			
            if(varProductId == "")
            {
            	jQuery('#js_addToCart').addClass("inactiveAddToCart");
				jQuery('#js_addToWishlist').addClass("inactiveAddToWishlist");
			}
			else 
			{
				setProductStock(sku);
			}
			
			if(noSelection=="true" || varProductId == "")
			{
            	var indexDisplayed = 1;
            	varProductId = document.forms["addform"].elements[name].options[indexDisplayed].value;
            }
        
            if(jQuery('#js_mainImage_'+varProductId).length) 
            {
	            var variantMainImages = jQuery('#js_mainImage_'+varProductId).clone();
	            //jQuery(variantMainImages).find('img').each(function(){jQuery(this).attr('src', jQuery(this).attr('title')+ "?" + new Date().getTime());})
	            jQuery(variantMainImages).find('a').attr('class', 'innerZoom');
	            detailImgUrl = jQuery(variantMainImages).find('a').attr('href');
	            jQuery('#js_productDetailsImageContainer').html(variantMainImages.html());
	        }
	        
	        var variantAltImages = jQuery('#js_altImage_'+varProductId).clone();
        	var variantProductVideo = jQuery('#js_productVideo_'+varProductId).html();
        	var variantProductVideoLink = jQuery('#js_productVideoLink_'+varProductId).html();
        	var variantProductVideo360 = jQuery('#js_productVideo360_'+varProductId).html();
        	var variantProductVideo360Link = jQuery('#js_productVideo360Link_'+varProductId).html();
        	var variantPdpPriceSavingMoney = jQuery('#js_pdpPriceSavingMoney_'+varProductId).html();
        	var variantPdpPriceSavingPercent = jQuery('#js_pdpPriceSavingPercent_'+varProductId).html();
        	var variantPdpVolumePricing = jQuery('#js_pdpVolumePricing_'+varProductId).html();
        	var variantPdpPriceList = jQuery('#js_pdpPriceList_'+varProductId).html();
        	var variantPdpPriceOnLine = jQuery('#js_pdpPriceOnLine_'+varProductId).html();
	            
            if(noSelection=="true" || varProductId == "")
            {
            	var variantLargeImages = jQuery('#js_largeImageUrl_Virtual').clone();
            	var variantPdpLongDescription = jQuery('#js_pdpLongDescription_Virtual').html();
            	var variantPdpDistinguishingFeature = jQuery('#js_pdpDistinguishingFeature_Virtual').html();
            }
            else
            {
            	var variantLargeImages = jQuery('#js_largeImageUrl_'+varProductId).clone();
            	var variantPdpLongDescription = jQuery('#js_pdpLongDescription_'+varProductId).html();
            	var variantPdpDistinguishingFeature = jQuery('#js_pdpDistinguishingFeature_'+varProductId).html();
            }
            
            //jQuery(variantAltImages).find('img').each(function(){jQuery(this).attr('src', jQuery(this).attr('title')+ "?" + new Date().getTime());})
            jQuery('#js_eCommerceProductAddImage').html(variantAltImages.html());
			jQuery(variantLargeImages).find('.js_mainImageLink').attr('id', 'js_mainImageLink');
            jQuery('#js_seeLargerImage').html(variantLargeImages.html());
            jQuery('#js_productVideo').html(variantProductVideo);
            jQuery('#js_productVideoLink').html(variantProductVideoLink);
            jQuery('#js_productVideo360').html(variantProductVideo360);
            jQuery('#js_productVideo360Link').html(variantProductVideo360Link);
            jQuery('#js_pdpPriceSavingMoney').html(variantPdpPriceSavingMoney);
            jQuery('#js_pdpPriceSavingPercent').html(variantPdpPriceSavingPercent);
			jQuery('#js_pdpVolumePricing').html(variantPdpVolumePricing);
            jQuery('#js_pdpPriceList').html(variantPdpPriceList);
            jQuery('#js_pdpPriceOnLine').html(variantPdpPriceOnLine);
            jQuery('#js_pdpLongDescription').html(variantPdpLongDescription);
            jQuery('#js_pdpDistinguishingFeature').html(variantPdpDistinguishingFeature);
            
        }
        activateZoom(detailImgUrl);
        activateScroller();
    }


    function activateZoom(imgUrl) 
    {
        if (typeof imgUrl == "undefined" || imgUrl == "NULL" || imgUrl == "") 
        {
            return;
        }
        var image = new Image();
        image.src = imgUrl+ "?" + new Date().getTime();
        image.onerror = function () 
        {
            jQuery('.innerZoom').attr('href', 'javaScript:void(0);');
            return false;
        };
        image.onload = function () 
        {
            jQuery('.innerZoom').jqzoom(zoomOptions);
        };
        
    }
    
    function activateInitialZoom() 
    {
        jQuery('.innerZoom').each(function() 
        {
            var elm = this;
            var image = new Image();
            image.src = this.href+ "?" + new Date().getTime();
            image.onerror = function () 
            {
                jQuery(elm).attr('href', 'javaScript:void(0);');
                return false;
            };
            image.onload = function () 
            {
                jQuery(this).jqzoom(zoomOptions);
            };
        });
    }

    function activateScroller() 
    {
        <#if Static["com.osafe.util.Util"].isProductStoreParmTrue(request,"PDP_ALT_IMG_SCROLLER_ACTIVE")>
            if(!jQuery('#js_altImageThumbnails').length) 
            {
                jQuery('#js_eCommerceProductAddImage').find('ul').attr('id', 'js_altImageThumbnails');
            }
            jQuery('#js_altImageThumbnails').addClass('imageScroller');
            jQuery('#js_altImageThumbnails').jcarousel(
            {
                <#if Static["com.osafe.util.Util"].isProductStoreParmTrue(request,"PDP_ALT_IMG_SCROLLER_VERTICAL")>
                    vertical: true,
                </#if>
                scroll: ${PDP_ALT_IMG_SCROLLER_IMAGES!"2"},
                itemFallbackDimension: 300
            });
        </#if>
    }

    function showProductVideo(videoDivClass)
    {
        if (jQuery.browser.msie) jQuery('object > embed').unwrap(); 
        videoDiv = '.'+ videoDivClass;
        jQuery('#js_productDetailsImageContainer').html(jQuery(videoDiv).clone().removeClass(videoDivClass).show());
    }

	jQuery(function() 
	{
		jQuery(".js_pdpTabs").tabs();
	});

    var zoomOptions = {
        zoomType: 'innerzoom',
        lens:true,
        preloadImages: true,
        preloadText: ''
    };


    function makeProductUrl(elm) 
    {
        var plpFeatureSwatchImageId = jQuery(elm).attr("id");
        var plpFeatureSwatchImageIdArr = plpFeatureSwatchImageId.split("|");
        var pdpUrlId = plpFeatureSwatchImageIdArr[1]+plpFeatureSwatchImageIdArr[0]; 
        var pdpUrl = document.getElementById(pdpUrlId).value;
        
        jQuery(elm).parents('.productItem').find('.js_eCommerceThumbNailHolder').find('.js_swatchProduct').find('a').attr("href",pdpUrl);
        jQuery(elm).parents('.productItem').find('a.js_pdpUrl').attr("href",pdpUrl);
        jQuery(elm).parents('.productItem').find('a.js_pdpUrl.js_review').attr("href",pdpUrl+"#productReviews");
    }
</#if>

 </script>
