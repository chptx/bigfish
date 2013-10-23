<script type="text/javascript">

    var displayDialogId;
    var myDialog;
    var titleText;
    function displayDialogBox(dialogPurpose) {
       var dialogId = '#' + dialogPurpose + 'dialog';
       displayDialogId = '#' + dialogPurpose + 'displayDialog';
       dialogTitleId = '#' + dialogPurpose + 'dialogBoxTitle';
       titleText = jQuery(dialogTitleId).val();
       showDialog(dialogId, displayDialogId, titleText);
    }
   
    function showDialog(dialog, displayDialog, titleText) {
        myDialog = jQuery(displayDialog).dialog({
            modal: true,
            draggable: true,
            resizable: true,
            width: 'auto',
            autoResize: true,
            position: 'center',
            title: titleText
        });
        jQuery(myDialog).parent().addClass('uiDialogBox');
        var dialogClass = displayDialog;
        dialogClass = dialogClass.replace(/^#+/, "");
        jQuery(myDialog).parent().addClass(dialogClass);
        // adjust titlebar width mannualy - Workaround for IE7 titlebar width bug
        jQuery(myDialog).siblings('.ui-dialog-titlebar').width(jQuery(myDialog).width());
    }
    
    function confirmDialogResult(result, dialogPurpose) {
        dialogId = '#'+ dialogPurpose +'dialog';
        displayDialogId = '#'+ dialogPurpose +'displayDialog';
        jQuery(displayDialogId).dialog('close');
        if (result == 'Y') {
            postConfirmDialog();
        }
    }
    function postConfirmDialog() {
        form = document.${commonConfirmDialogForm!"detailForm"};
        form.action="<@ofbizUrl>${commonConfirmDialogAction!"confirmAction"}</@ofbizUrl>";
        form.submit();
    }
    // Popup window code
    function newPopupWindow(url) {
        popupWindow = window.open(
            url,'popUpWindow','height=350,width=500,left=400,top=200,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes')
    }
    function deleteConfirm(appendText)
    {
        jQuery('.confirmTxt').html('${confirmDialogText!""} '+appendText+'?');
        displayDialogBox('confirm_');
    }
    function submitSearchForm(form) {
        var searchText = form.searchText.value;
        <#assign SEARCH_DEFAULT_TEXT = Static["com.osafe.util.Util"].getProductStoreParm(request,"SEARCH_DEFAULT_TEXT")!""/>
        if(searchText == "" || searchText == "${StringUtil.wrapString(SEARCH_DEFAULT_TEXT!)}") {
            displayDialogBox('search_');
            return false;
        } else {
            form.submit();
        }
    }
    
    function prepareActionDialog(dialogPurpose) 
    {
       //when dialog first appears, it will display whatever error is in context. So we need to hide it
       jQuery('#'+ dialogPurpose +'displayDialog').find('.eCommerceErrorMessage').hide();
        
    }
   
    function displayActionDialogBox(dialogPurpose,elm) 
    {
       var params = jQuery(elm).siblings('input.param').serialize();
       var dialogId = '#' + dialogPurpose + 'dialog';
       var displayContainerId = '#js_' + dialogPurpose + 'Container';
       displayDialogId = '#' + dialogPurpose + 'displayDialog';
       dialogTitleId = '#' + dialogPurpose + 'dialogBoxTitle';
       titleText = jQuery(dialogTitleId).val();
       jQuery(displayContainerId).html('<div id=loadingImg></div>');
       getActionDialog(displayContainerId,params);
       showDialog(dialogId, displayDialogId, titleText);
        
    }
   
    function displayProductScrollActionDialogBox(dialogPurpose,elm) 
    {
       var params = jQuery(elm).siblings('input.param').serialize();
       var dialogId = '#' + dialogPurpose + 'dialog';
       var displayContainerId = '#' + dialogPurpose + 'Container';
       displayDialogId = '#' + dialogPurpose + 'displayDialog';
       dialogTitleId = '#' + dialogPurpose + 'dialogBoxTitle';
       titleText = jQuery(dialogTitleId).val();
       jQuery(displayContainerId).html('<div id=loadingImg></div>');
       getActionDialog(displayContainerId,params);
        
    }
   
  function getActionDialog (displayContainerId,params) 
  {
      var url = "";
      if (params)
      {
          url = '${dialogActionRequest!"dialogActionRequest"}?'+params;
      } else {
          url = '${dialogActionRequest!"dialogActionRequest"}';
      }
      jQuery.get(url, function(data)
      {
          jQuery(displayContainerId).replaceWith(data);
          //jQuery(myDialog).dialog( "option", "position", 'center' );
      });
  }

    var isWhole_re = /^\s*\d+\s*$/;
    function isWhole (s) {
        return String(s).search (isWhole_re) != -1
    }

    function onImgError(elem,type) {
      var imgUrl = "/osafe_theme/images/user_content/images/";
      var imgName= "NotFoundImage.jpg";
      switch (type) {
        case "PLP-Thumb":
          imgName="NotFoundImagePLPThumb.jpg";
          break;
        case "PLP-Swatch":
          imgName="NotFoundImagePLPSwatch.jpg";
          break;
        case "PDP-Large":
          imgName="NotFoundImagePDPLarge.jpg";
          break;
        case "PDP-Alt":
          imgName="NotFoundImagePDPAlt.jpg";
          break;
        case "PDP-Detail":
          imgName="NotFoundImagePDPDetail.jpg";
          break;
        case "PDP-Swatch":
          imgName="NotFoundImagePDPSwatch.jpg";
          break;
        case "CLP-Thumb":
          imgName="NotFoundImageCLPThumb.jpg";
          break;
        case "MANU-Image":
          imgName="NotFoundImage.jpg";
          break;
      }
      elem.src = imgUrl + imgName;
      // disable onerror to prevent endless loop
      elem.onerror = "";
      return true;
    }
    
    // utility function to retrieve a future expiration date in proper format;
    // pass three integer parameters for the number of days, hours,
    // and minutes from now you want the cookie to expire; all three
    // parameters required, so use zeros where appropriate
    function getExpDate(days, hours, minutes) {
        var expDate = new Date();
        if (typeof days == "number" && typeof hours == "number" && typeof hours == "number") {
            expDate.setDate(expDate.getDate() + parseInt(days));
            expDate.setHours(expDate.getHours() + parseInt(hours));
            expDate.setMinutes(expDate.getMinutes() + parseInt(minutes));
            return expDate.toGMTString();
        }
    }
    
    // utility function called by getCookie()
    function getCookieVal(offset) {
        var endstr = document.cookie.indexOf (";", offset);
        if (endstr == -1) {
            endstr = document.cookie.length;
        }
        return unescape(document.cookie.substring(offset, endstr));
    }
    
    // primary function to retrieve cookie by name
    function getCookie(name) {
        var arg = name + "=";
        var alen = arg.length;
        var clen = document.cookie.length;
        var i = 0;
        while (i < clen) {
            var j = i + alen;
            if (document.cookie.substring(i, j) == arg) {
                return getCookieVal(j);
            }
            i = document.cookie.indexOf(" ", i) + 1;
            if (i == 0) break; 
        }
        return null;
    }
    
    // store cookie value with optional details as needed
    function setCookie(name, value, expires, path, domain, secure) {
        document.cookie = name + "=" + escape (value) +
            ((expires) ? "; expires=" + expires : "") +
            ((path) ? "; path=" + path : "") +
            ((domain) ? "; domain=" + domain : "") +
            ((secure) ? "; secure" : "");
    }
    
    // remove the cookie by setting ancient expiration date
    function deleteCookie(name,path,domain) {
        if (getCookie(name)) {
            document.cookie = name + "=" +
                ((path) ? "; path=" + path : "") +
                ((domain) ? "; domain=" + domain : "") +
                "; expires=Thu, 01-Jan-70 00:00:01 GMT";
        }
    }
    
 //Light Box Cart

    jQuery(document).ready(function () 
    {
    
        jQuery('.dateEntry').each(function(){datePicker(this);});
       
        jQuery('.showLightBoxCart').hover(
            function(e) {
               <#assign shoppingCart = Static["org.ofbiz.order.shoppingcart.ShoppingCartEvents"].getCartObject(request)! />  
                    <#if shoppingCart?has_content >
                        <#assign cartCount = shoppingCart.getTotalQuantity()!"0" />
                        <#assign cartSubTotal = shoppingCart.getSubTotal()!"0" />
                    </#if>
                    <#if (cartCount?if_exists > 0) >
                        e.preventDefault();
                        displayLightDialogBox('lightCart_');
                        var dialogHolder = jQuery('#lightCart_displayDialog').parent();
                        jQuery(dialogHolder).hide();
                        var x = jQuery(this).offset().left - jQuery(this).outerWidth() + 25; //the plus 25 is temporary until CSS changes are complete to avoid unwanted mouseout from triggering
                        var y = jQuery(this).offset().top - jQuery(document).scrollTop() + jQuery(this).outerHeight();
                        jQuery(dialogHolder).css('left', x + 'px');
                        jQuery(dialogHolder).css('top', y + 'px');
                        jQuery(dialogHolder).slideDown(850);
                        jQuery(dialogHolder).addClass('js_lightBoxCartContainer');
                        var titlebar = jQuery(dialogHolder).find(".ui-dialog-titlebar");
                        jQuery(titlebar).attr('id', 'js_lightBoxCartTitleBar');
                        jQuery('.js_lightBoxCartContainer').attr('id', 'js_lightBoxCartContainerId');
                    </#if>
            },
            function() {
                //do nothing. Let functions below handle mouseout
            }
        );
        
        <#assign lightDelayMs = Static["com.osafe.util.Util"].getProductStoreParm(request,"LIGHTBOX_DELAY_MS")!0/>  
        jQuery('#eCommerceNavBar').mouseover(function(e){
            var id = e.target.id;
            if((id != "lightCart_displayDialog") && (id != "js_lightBoxCartTitleBar"))
            {
                jQuery('.js_lightBoxCartContainer').delay(${lightDelayMs}).slideUp(850, function() {
                jQuery('.js_lightBoxCartContainer').remove();  
                }); 
            }
        }); 
        jQuery('#eCommercePageBody').mouseover(function(e){
            var id = e.target.id;
            if((id != "lightCart_displayDialog") && (id != "js_lightBoxCartTitleBar"))
            {
                jQuery('.js_lightBoxCartContainer').delay(${lightDelayMs}).slideUp(850, function() {
                jQuery('.js_lightBoxCartContainer').remove();  
                }); 
            }
        });
        jQuery('#eCommerceHeader').mouseover(function(e){
            var id = e.target.id;
            if((id != "siteShoppingCartSize") && (id != "lightCart_displayDialog"))
            {
                jQuery('.js_lightBoxCartContainer').delay(${lightDelayMs}).slideUp(850, function() {
                jQuery('.js_lightBoxCartContainer').remove();  
                }); 
            }
        });
        
        jQuery(window).scroll(function(){
         var heightBody = jQuery('#eCommercePageBody').height(); 
         var y = jQuery(window).scrollTop(); 
         if( y > (heightBody*.10) )
         {
           jQuery(".js_scrollToTop").fadeIn("slow"); 
         }
         else
         {
          jQuery('.js_scrollToTop').fadeOut('slow');
         }
        });          
        
        var autoSuggestionList = [""];
        jQuery(function() 
        {
            jQuery("#searchText").autocomplete({source: autoSuggestionList});
        });
        
        jQuery("#searchText").keyup(function(e) 
        {
            var keyCode = e.keyCode;
            if(keyCode != 40 && keyCode != 38)
            {
              var searchText = jQuery(this).attr('value');
            
              jQuery("#searchText").autocomplete({
                appendTo:"#searchAutoComplete",
                source: function(request, response) {
                jQuery.ajax({
                    url: "<@ofbizUrl secure="${request.isSecure()?string}">findAutoSuggestions?searchText="+searchText+"</@ofbizUrl>",
                    dataType: "json",
                    type: "POST",
                    success: function(data) {
                    if(data.autoSuggestionList != null)
                    {
                        response(jQuery.map(data.autoSuggestionList, function(item) 
                        {
                            return {
                                value: item
                            }
                        }))
                    }
                    else
                    {
                        response(function() {
                            return {
                                value: ""
                            }
                        })
                    }
                }
                
            });
          },
          minLength: 1
          });
        }
    });
        
    jQuery('.checkDelivery').click(function(e)
    {
        displayActionDialogBox('pincodeChecker_',this);
    });
        
    jQuery('.pincodeChecker_Form').submit(function(event) 
    {
            event.preventDefault();
            jQuery.get(jQuery(this).attr('action')+'?'+jQuery(this).serialize(), function(data) 
            {
                jQuery('#js_pincodeCheckContainer').replaceWith(data);
            });
    });
    
    jQuery('.js_cancelPinCodeChecker').click(function(event) {
            event.preventDefault();
            jQuery(displayDialogId).dialog('close');
    });
    
    });
    
    function displayLightDialogBox(dialogPurpose) {
       var dialogId = '#' + dialogPurpose + 'dialog';
       displayDialogId = '#' + dialogPurpose + 'displayDialog';
       dialogTitleId = '#' + dialogPurpose + 'dialogBoxTitle';
       titleText = jQuery(dialogTitleId).val();
       showLightBoxDialog(dialogId, displayDialogId, titleText);
    }
    
    function showLightBoxDialog(dialog, displayDialog, titleText) {
        myDialog = jQuery(displayDialog).dialog({
            modal: false,
            draggable: true,
            resizable: true,
            width: 'auto',
            autoResize:true,
            position: 'center',
            title: titleText
        });
        var dialogClass = displayDialog;
        dialogClass = dialogClass.replace(/^#+/, "");
        jQuery(myDialog).parent().addClass(dialogClass);
        // adjust titlebar width mannualy - Workaround for IE7 titlebar width bug
        jQuery(myDialog).siblings('.ui-dialog-titlebar').width(jQuery(myDialog).width());
    }
    
    
    function datePicker(triger)
    {
	   jQuery(triger).datepicker({
	       showOn: 'button',
	       buttonImage: '<@ofbizContentUrl>/images/cal.gif</@ofbizContentUrl>',
	       buttonImageOnly: false,
	       <#if preferredDateFormat?exists && preferredDateFormat?has_content>
	         <#assign format = StringUtil.wrapString(preferredDateFormat.toLowerCase()) />
	         <#assign format = format?replace("yy", "y") />
	       <#else>
	         <#assign format = "mm/dd/y" />
	       </#if>
	       dateFormat: '${format}'
	   });
 }
//end Light Box Cart

    function addMultiOrderItems() 
    {
    	var submitToCart = "true";
    	var atleastOneItemGreaterThanZero = "false";
    	var atleastOneItemGreaterThanMaxQty = "false";
    	var atleastOneItemLessThanMinQty = "false";
    	var atleastOneItemNotWholeQty = "false";
    	var atleastOneItemSelected = "false";
    	
    	<#assign PDP_QTY_MIN = Static["com.osafe.util.Util"].getProductStoreParm(request,"PDP_QTY_MIN")!"1"/>
		<#assign PDP_QTY_MAX = Static["com.osafe.util.Util"].getProductStoreParm(request,"PDP_QTY_MAX")!"99"/> 
		var lowerLimit = ${PDP_QTY_MIN!"1"};
		var upperLimit = ${PDP_QTY_MAX!"99"};
    	//loop through each variant
    	var count = 0;
    	
    	jQuery('.js_add_multi_product_quantity').each(function () 
    	{
    	    reOrderQtyIdArr = jQuery(this).attr("id").split("_");
    	    variantIsChecked = jQuery('#js_add_multi_product_id_'+reOrderQtyIdArr[5]).is(":checked");
    		if(variantIsChecked)
    		{
    		    atleastOneItemSelected = "true";
	    		var quantity = jQuery(this).val();
	    		
	    		var add_productId = jQuery('#js_add_multi_product_id_'+reOrderQtyIdArr[5]).val();
	    		var qtyInCart = Number(jQuery('#js_qtyInCart_'+add_productId).val());
	    		
	    		//check for valid numbers within range of sys params
	        	if(quantity != "") 
				{
				    atleastOneItemGreaterThanZero = "true";
			        if(quantity < lowerLimit)
			        {
			            atleastOneItemLessThanMinQty = "true";
			            submitToCart = "false";
			        }
			        if(upperLimit!= 0 && (Number(quantity) +qtyInCart) > upperLimit)
			        {
			            atleastOneItemGreaterThanMaxQty = "true";
			            submitToCart = "false";
			        }
			        if(!isWhole(quantity))
			        {
			            atleastOneItemNotWholeQty = "true";
			            submitToCart = "false";
			        }
			    }
		  }
		  count = count + 1;
			
		});   		
		
		if(submitToCart == "true" && atleastOneItemGreaterThanZero == "true")
		{
	    	// add to cart action
	        document.reOrderItemForm.action="<@ofbizUrl>${addMultiItemsToCartAction!""}</@ofbizUrl>";
	        document.reOrderItemForm.submit();
        }
        
		if(submitToCart == "false" && atleastOneItemGreaterThanMaxQty == "true")
		{
		    alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMaxQtyError,'\"','\\"'))}");
		}
		if(submitToCart == "false" && atleastOneItemNotWholeQty == "true")
		{
		    alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPQtyDecimalNumberError,'\"','\\"'))}");
		}
		if(atleastOneItemSelected == "false")
		{
			alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.NoOrderItemsSelectedError,'\"','\\"'))}");
		}
		else if(atleastOneItemGreaterThanZero == "false")
		{
		    alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMinQtyError,'\"','\\"'))}");
		}
		else if(submitToCart == "false" && atleastOneItemLessThanMinQty == "true")
		{
		    alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMinQtyError,'\"','\\"'))}");
		}
    }
    
    function seqReOrderCheck(elm)
    {
        reOrderQtyIdArr = jQuery(elm).attr("id").split("_");
        if(jQuery(elm).val()=="")
        {
            jQuery('#js_add_multi_product_id_'+reOrderQtyIdArr[5]).attr("checked", false);
        }
        else
        {
            jQuery('#js_add_multi_product_id_'+reOrderQtyIdArr[5]).attr("checked", true);
        }
        
    }
    function findOrderItems(elm) 
    {
        document.reOrderItemSearchForm.action="<@ofbizUrl>eCommerceReOrderItems</@ofbizUrl>";
	    document.reOrderItemSearchForm.submit();
    }
    
    function showTooltip(text, elm)
    {
        var tooltipBox = jQuery('.js_tooltip')[0];
	    var obj2 = jQuery('.js_tooltipText')[0];
	    obj2.innerHTML = text;
	    tooltipBox.style.display = 'block';
	    <#assign decorator = "${parameters.eCommerceDecoratorName!}"/>
	    //get the ScrollTop and ScrollLeft to add in top and left postion of tooltip.
	    var st = Math.max(document.body.scrollTop,document.documentElement.scrollTop);
	    var sl = Math.max(document.body.scrollLeft,document.documentElement.scrollLeft);
	    
	    /*determine the margin between window left edge and  main content screen.
	      when we set the left position of tooltip using tooltip.style.left, it sets the position from main content screen. 
	      So we need to subtract the eCommerceContentLeftPos from Element X position. */ 
	      <#if decorator == 'ecommerce-basic-bevel-decorator'>
	          var eCommerceContentLeftPos = 0;
	      <#else>
	          var eCommerceContentLeftPos = jQuery('#eCommerceContent').offset().left;
	      </#if>
	    
	    var WW = jQuery(window).width();
	    var WH = jQuery(window).height();
	    
	    //subtracting the sl and st from element left and top position because element left and top includes the scroll pixels. 
	    var EX = jQuery(elm).children().offset().left - sl;
	    var EY = jQuery(elm).children().offset().top - st;
	    
	    var TTW = jQuery(tooltipBox).width();
	    var TTH = jQuery(tooltipBox).height();
	    var LP = 0;
	    var TP = 0;
	    var EH = jQuery(elm).children().height();
		var EW = jQuery(elm).children().width();
	    
	    var TOP = eval(EY > TTH);
	    var BOTTOM = eval(!(TOP));
	    var LEFT = eval((TTW + EX) > WW);
	    var RIGHT = eval(!(LEFT));
	    
	    /*These TOP, BOTTOM, LEFT and RIGHT are the position of tooltip and our arrow would be opposite from the tootip, 
	      means if tooltip is on TOP then the Arrow would be at bottom of tooltip. 
	      If the tooltip is in LEFT then the Arrow would be in right of the tooltip. */
	    
	    if(BOTTOM && LEFT)
	    {
	        jQuery('.js_tooltipTop').removeClass("tooltipTopLeftArrow");
	        jQuery('.js_tooltipBottom').removeClass("tooltipBottomRightArrow");
	        jQuery('.js_tooltipBottom').removeClass("tooltipBottomLeftArrow");
	        jQuery('.js_tooltipTop').addClass("tooltipTopRightArrow");
	    }
	    else if(BOTTOM && RIGHT)
	    {
	        jQuery('.js_tooltipTop').removeClass("tooltipTopRightArrow");
	        jQuery('.js_tooltipBottom').removeClass("tooltipBottomRightArrow");
	        jQuery('.js_tooltipBottom').removeClass("tooltipBottomLeftArrow");
	        jQuery('.js_tooltipTop').addClass("tooltipTopLeftArrow");
	    }
	    else if(TOP && LEFT)
	    {
	        jQuery('.js_tooltipTop').removeClass("tooltipTopLeftArrow");
	        jQuery('.js_tooltipTop').removeClass("tooltipTopRightArrow");
	        jQuery('.js_tooltipBottom').removeClass("tooltipBottomLeftArrow");
	        jQuery('.js_tooltipBottom').addClass("tooltipBottomRightArrow");
	    }
	    else if(TOP && RIGHT)
	    {
	        jQuery('.js_tooltipTop').removeClass("tooltipTopLeftArrow");
	        jQuery('.js_tooltipBottom').removeClass("tooltipBottomRightArrow");
	        jQuery('.js_tooltipTop').removeClass("tooltipTopRightArrow");
	        jQuery('.js_tooltipBottom').addClass("tooltipBottomLeftArrow");
	    }
	    
	    //determine the left position and top position to set to the tooltip
	    if(LEFT)
	    {
	       //adding Element Width EW so that the tooltip starts (horizontally) from right of the icon.
	       LP = EX - eCommerceContentLeftPos -TTW + sl + EW; 
	    }
	    else
	    {
	       LP = EX - eCommerceContentLeftPos + sl;
	    }
	    
	    if(BOTTOM)
	    {
	        //adding Element Height EH so that the tooltip starts(vertically) from bottom of the icon.
	        TP = (EY + st + EH);
	    }
	    else
	    {
	        TP = (EY- TTH + st);
	    }
	    jQuery(tooltipBox).css({ top: TP+'px' });
	    jQuery(tooltipBox).css({ left: LP+'px' }); 
    }
    
    function hideTooltip()
    {
        document.getElementById('tooltip').style.display = "none";
    }
    
    //Add To Cart from PLP
    function plpAddItems(type,plpProductId,plpCategoryId,plpProductName,plpQtyInputSuffix) 
    {
    	//set the values of these hidden inputs to be submitted when adding to cart
    	jQuery('input[name="plp_add_product_id"]').val(plpProductId);
    	jQuery('input[name="plp_add_category_id"]').val(plpCategoryId);
    	jQuery('input[name="plp_add_product_name"]').val(plpProductName);
    	//get the value of the quantity you have selected to add to cart and set it to hidden quantity input
    	var quantityVal = jQuery("#js_quantity_" + plpProductId + "_" + plpQtyInputSuffix).val();
    	jQuery('input[name="plp_qty"]').val(quantityVal);
    	
    	<#assign PDP_QTY_MIN = Static["com.osafe.util.OsafeAdminUtil"].getProductStoreParm(request,"PDP_QTY_MIN")!"1"/>
		<#assign PDP_QTY_MAX = Static["com.osafe.util.OsafeAdminUtil"].getProductStoreParm(request,"PDP_QTY_MAX")!"99"/> 
    
       var quantity = jQuery('input[name="plp_qty"]').val();
       
       var qtyInCart = Number(0);
       var totalQty = quantity;
       if(jQuery("#js_qtyInCart_" + plpProductId + "_" + plpQtyInputSuffix).length)
       {
           qtyInCart = Number(jQuery("#js_qtyInCart_" + plpProductId + "_" + plpQtyInputSuffix).val());
           if(isWhole(qtyInCart))
	       {
	       		totalQty = +totalQty + +qtyInCart;
	       }
       }

       var lowerLimit = ${PDP_QTY_MIN!"1"};
       var upperLimit = ${PDP_QTY_MAX!"99"};
        
       if(quantity < lowerLimit)
       {
            alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMinQtyError,'\"','\\"'))}");
            return false;
       }
       
       if(upperLimit!= 0 && totalQty > upperLimit)
       {
            alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMaxQtyError,'\"','\\"'))}");
            return false;
       }
       
       if(!isWhole(quantity))
       {
            alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPQtyDecimalNumberError,'\"','\\"'))}");
            return false;
       }
       
       if(plpQtyInputSuffix == "PLP")
       {
       		if(type == "plpAddToCart")
	       	{
	           // add to cart action
	           document.productListForm.action="<@ofbizUrl>${addToCartPlpAction!""}</@ofbizUrl>";
	           document.productListForm.submit();
	       	}
	       	else if (type == "plpAddToWishlist")
	       	{
	           // add to wish list action
	           document.productListForm.action="<@ofbizUrl>${addToWishListPlpAction!""}</@ofbizUrl>";
	           document.productListForm.submit();
	       	}
       }
       else
       {
       		if(type == "plpAddToCart")
		    {
		        // add to cart action
		        document.addform.action="<@ofbizUrl>${addToCartPlpAction!""}</@ofbizUrl>";
		        document.addform.submit();
		    }
		    else if (type == "plpAddToWishlist")
		    {
		        // add to wish list action
		        document.addform.action="<@ofbizUrl>${addToWishListPlpAction!""}</@ofbizUrl>";
		        document.addform.submit();
		    }
       }
    }
    
    function addMultiItems(pdpSelectMultiVariant, id) 
    {
    	var submitToCart = "true";
    	var atleastOneItemGreaterThanZero = "false";
    	var atleastOneItemGreaterThanMaxQty = "false";
    	var atleastOneItemLessThanMinQty = "false";
    	var atleastOneItemNotWholeQty = "false";
    	
		var lowerLimit = Number(${PDP_QTY_MIN!});
		var upperLimit = Number(${PDP_QTY_MAX!});
    	//loop through each variant
    	var count = 0;
    	jQuery('.js_add_multi_product_quantity').each(function () 
    	{
    		if(pdpSelectMultiVariant == "CHECKBOX")
    		{
    			variantIsChecked = jQuery('#js_add_multi_product_id_'+count).is(":checked");
    		}
    		else
    		{
    			//does not apply
    			variantIsChecked = true;
    		}
    		if(variantIsChecked)
    		{
	    		var quantity = jQuery(this).val();
	    		
	    		var add_productId = jQuery('#js_add_multi_product_id_'+count).val();
                var qtyInCart = Number(jQuery('#js_qtyInCart_'+add_productId).val());
	    		//check for valid numbers within range of sys params
	        	if(quantity != "") 
				{
				    atleastOneItemGreaterThanZero = "true";
			        if(quantity < lowerLimit)
			        {
			            atleastOneItemLessThanMinQty = "true";
			            submitToCart = "false";
			        }
			        if(upperLimit!= 0 && (Number(quantity) +qtyInCart) > upperLimit)
			        {
			            atleastOneItemGreaterThanMaxQty = "true";
			            submitToCart = "false";
			        }
			        if(!isWhole(quantity))
			        {
			            atleastOneItemNotWholeQty = "true";
			            submitToCart = "false";
			        }
			    }
			     
		  }
		  count = count + 1;
			
		});
		if(submitToCart == "true" && atleastOneItemGreaterThanZero == "true" && id=="addToCart")
		{
	    	// add to cart action
	        document.addform.action="<@ofbizUrl>${addMultiItemsToCartAction!""}</@ofbizUrl>";
	        document.addform.submit();
        }
        if(submitToCart == "true" && atleastOneItemGreaterThanZero == "true" && id=="addToWishlist")
		{
	    	// add to cart action
	        document.addform.action="<@ofbizUrl>${addMultiItemsToWishlistAction!""}</@ofbizUrl>";
	        document.addform.submit();
        }   		
		if(submitToCart == "false" && atleastOneItemLessThanMinQty == "true")
		{
		    alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMinQtyError,'\"','\\"'))}");
		}
		if(submitToCart == "false" && atleastOneItemGreaterThanMaxQty == "true")
		{
		    alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMaxQtyError,'\"','\\"'))}");
		}
		if(submitToCart == "false" && atleastOneItemNotWholeQty == "true")
		{
		    alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPQtyDecimalNumberError,'\"','\\"'))}");
		}
		if(atleastOneItemGreaterThanZero == "false")
		{
		    alert("${StringUtil.wrapString(StringUtil.replaceString(uiLabelMap.PDPMinQtyError,'\"','\\"'))}");
		}
    }
</script>