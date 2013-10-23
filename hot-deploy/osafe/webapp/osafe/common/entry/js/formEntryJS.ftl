<script type="text/javascript">

  lastFocusedName = null;
  function setLastFocused(formElement) {
    lastFocusedName = formElement.name;
  }

  function changeEmail() {
    jQuery('#js_USERNAME').val(jQuery('#js_CUSTOMER_EMAIL').val());
  }

  jQuery(document).ready(function () 
  {
    if (jQuery('#js_BILLING_ADDRESS_ENTRY').length && jQuery('#js_SHIPPING_ADDRESS_ENTRY').length && jQuery('#js_isSameAsBilling').length && jQuery('#js_SHIPPING_AddressSection').length) {
      copyAddress('BILLING', jQuery('#js_BILLING_ADDRESS_ENTRY'), 'SHIPPING', jQuery('#js_SHIPPING_AddressSection'), jQuery('#js_isSameAsBilling'), true);
    }

    if(jQuery('#js_content').length) {
        var curLen = jQuery('#js_content').val().length;
        jQuery('#js_textCounter').html(255 - curLen+" ${uiLabelMap.CharactersLeftLabel}");
        jQuery('#js_content').bind('keyup', function() {
            var maxchar = 255;
            var cnt = jQuery(this).val().length;
            var remainingchar = maxchar - cnt;
            if(remainingchar < 0){
                jQuery('#js_textCounter').html('0 ${uiLabelMap.CharactersLeftLabel}');
                jQuery(this).val(jQuery(this).val().slice(0, maxchar));
            }else{
                jQuery('#js_textCounter').html(remainingchar+' ${uiLabelMap.CharactersLeftLabel}');
            }
        });
      }
    jQuery('.characterLimit').each(function(){
            restrictTextLength(this);
        });
  });

  function copyAddress(fromAddr, fromAddrContainer, toAddr, toAddrSection, triggerElt, isBlindup) {
    jQuery(fromAddrContainer).find('input, select, textarea').change(function(){
      if(jQuery(triggerElt).is(":checked")){
        copyFieldvalue(fromAddr, this, toAddr);
      }
    });
    if(jQuery(triggerElt).is(":checked") && jQuery(toAddrSection).length){
      if (isBlindup) {
        jQuery(toAddrSection).hide();
      }
      copyFieldsInitially(fromAddr, fromAddrContainer, toAddr, triggerElt);
    }
    jQuery(triggerElt).click(function(){
      if (isBlindup) {
        jQuery(toAddrSection).slideToggle(1000);
      }
      copyFieldsInitially(fromAddr, fromAddrContainer, toAddr, triggerElt);
    });
  }

  function copyFieldsInitially(fromAddr, fromAddrContainer, toAddr, triggerElt) {
    jQuery(fromAddrContainer).find('input, select, textarea').each(function(){
      if(jQuery(triggerElt).is(":checked")){
        copyFieldvalue(fromAddr, this, toAddr);
      }
    });
  }

  function copyFieldvalue(fromAddrPurpose, fromElm, toAddrPurpose) {
    fromElmId = jQuery(fromElm).attr('id');
    var toElmId = '#'+toAddrPurpose + fromElmId.sub(fromAddrPurpose, "");
    if(jQuery(toElmId).length) {
      if(fromElmId == fromAddrPurpose+'AddressContactMechId') {
          return;
      }
      jQuery(toElmId).val(jQuery(fromElm).val());
      jQuery(toElmId).change();
    }
  }


  function getAddressFormat(idPrefix) {
    var countryId = '#js_'+idPrefix+'_COUNTRY'
    if (jQuery(countryId).val() == "USA") {
      jQuery('.js_'+idPrefix+'_CAN').hide();
      jQuery('.js_'+idPrefix+'_OTHER').hide();
      jQuery('.js_'+idPrefix+'_USA').show();
    } else if (jQuery(countryId).val() == "CAN") {
      jQuery('.js_'+idPrefix+'_USA').hide();
      jQuery('.js_'+idPrefix+'_OTHER').hide();
      jQuery('.js_'+idPrefix+'_CAN').show();
    } else{
      jQuery('.js_'+idPrefix+'_USA').hide();
      jQuery('.js_'+idPrefix+'_CAN').hide();
      jQuery('.js_'+idPrefix+'_OTHER').show();
    }
  }

  //This method exists in geoAutoCompleter.js named 'getAssociatedStateList'. we have reused and customized.
  function getAssociatedStateList(countryId, stateId, errorId, divId) {
    var optionList = "";
    jQuery.ajaxSetup({async:false});
    jQuery.post("<@ofbizUrl>getAssociatedStateList</@ofbizUrl>", {countryGeoId: jQuery("#"+countryId).val()}, function(data) {
      var stateList = data.stateList;
      jQuery(stateList).each(function() {
        if (this.geoId) {
          optionList = optionList + "<option value = "+this.geoId+" >"+this.geoName+"</option>";
        } else {
          optionList = optionList + "<option value = >"+this.geoName+"</option>";
        }
      });
      jQuery("#"+stateId).html(optionList);
    });
  }

  function getPostalAddress(contactMechId, purpose) {
    jQuery.ajaxSetup({async:false});
    jQuery.post("<@ofbizUrl>getPostalAddress</@ofbizUrl>", {contactMechId: contactMechId}, function(data) {
    <#if Static["com.osafe.util.Util"].isProductStoreParmTrue(request,"COUNTRY_MULTI")>
        jQuery("#js_"+purpose+"_COUNTRY > option").each(function() {
            if (this.value == data.countryGeoId) {
               jQuery(this).attr('selected', 'selected');
               jQuery(this).change();
            }
        });
    <#else>
        jQuery("#js_"+purpose+"_COUNTRY").val(data.countryGeoId);
    </#if>
       jQuery("#js_"+purpose+"_STATE > option").each(function() {
        if (this.value ==data.stateProvinceGeoId) {
           jQuery(this).attr('selected', 'selected');
        }
    });
    jQuery("#"+purpose+"AddressContactMechId").val(data.contactMechId);
    if(jQuery("#js_"+purpose+"_FULL_NAME").length )
    {
    	jQuery("#js_"+purpose+"_FULL_NAME").val(data.toName);
    }
    else
    {
    	var firstName = "";
    	var lastName = "";
    	var toNameString = data.toName;
    	if (toNameString != "" && (typeof toNameString != "undefined"))
    	{
	    	var toNameArray = toNameString.split(' ');
	    	var toNameArraySize = toNameArray.length;
	    	if(toNameArraySize > 0)
    		{
		    	firstName = toNameArray[0];
		    	if(toNameArraySize > 1)
    			{
		    		lastName = toNameArray[toNameArraySize - 1];
		    	}
	    	}
    	}
    	
    	jQuery("#js_"+purpose+"_FIRST_NAME").val(firstName);
    	jQuery("#js_"+purpose+"_LAST_NAME").val(lastName);
    }
    jQuery("#js_"+purpose+"_ADDRESS1").val(data.address1);
    jQuery("#js_"+purpose+"_ADDRESS2").val(data.address2);
    jQuery("#js_"+purpose+"_ADDRESS3").val(data.address3);
    jQuery("#js_"+purpose+"_CITY").val(data.city);
    jQuery("#js_"+purpose+"_POSTAL_CODE").val(data.postalCode);
    jQuery("#js_"+purpose+"_POSTAL_CODE").change();
    getAddressFormat(purpose);
    });
  }
 function restrictTextLength(textArea){
    var maxchar = jQuery(textArea).attr('maxlength');
    var curLen = jQuery(textArea).val().length;
    var regCharLen = lineBreakCount(jQuery(textArea).val());
    jQuery(textArea).next('.js_textCounter').html("* "+(maxchar - (curLen+regCharLen))+" ${uiLabelMap.CharactersLeftLabel}");
    jQuery(textArea).keyup(function() {
        var cnt = jQuery(this).val().length;
        var regCharLen = lineBreakCount(jQuery(this).val());
        var remainingchar = maxchar - (cnt + regCharLen);
        if(remainingchar < 0){
            jQuery(this).next('.js_textCounter').html("* "+'0 ${uiLabelMap.CharactersLeftLabel}');
            jQuery(this).val(jQuery(this).val().slice(0, (maxchar-regCharLen)));
        } else{
            jQuery(this).next('.js_textCounter').html("* "+remainingchar+' ${uiLabelMap.CharactersLeftLabel}');
        }
    });
 }
  function lineBreakCount(str){
        /* counts \n */
        try {
            return((str.match(/[^\n]*\n[^\n]*/gi).length));
        } catch(e) {
            return 0;
        }
    }
    
    
    //set cell phone number to required based on user text messaging options
    jQuery(document).ready(function () {
        //when page first loads
        txtPreferenceSelected = jQuery("input[name='PARTY_TEXT_PREFERENCE']:checked").val();
        if(txtPreferenceSelected == "Y")
        {
            jQuery("#js_PHONE_MOBILE_REQUIRED").val("true");
        }
        else
        {
            jQuery("#js_PHONE_MOBILE_REQUIRED").val("false");
        }
        //when user changes preference
        jQuery("input[name='PARTY_TEXT_PREFERENCE']").change(function(){
            txtPreferenceSelected = jQuery(this).val();
            if(txtPreferenceSelected == "Y")
            {
                jQuery("#js_PHONE_MOBILE_REQUIRED").val("true");
            }
            else
            {
                jQuery("#js_PHONE_MOBILE_REQUIRED").val("false");
            }
        });
    });
    
    //when gift message text is empty and a help text is selected, copy the help text to the message
    function giftMessageHelpCopy(count)
    {
    	var messageText = jQuery("#js_giftMessageText_"+count).val();
    	if(messageText == "")
    	{
    		//if the message is blank then copy in the selected message from the Drop Down
    		var helpText = jQuery("#js_giftMessageEnum_"+count).val();
    		jQuery("#js_giftMessageText_"+count).val(helpText);
    	}
    }
    
    function setMaxLength(textArea)
    {
	        var maxchar = jQuery(textArea).attr('maxlength');
            var curLen = jQuery(textArea).val().length;
            var regCharLen = lineBreakCount(jQuery(textArea).val());
            jQuery(textArea).keyup(function() {
                var cnt = jQuery(this).val().length;
                var regCharLen = lineBreakCount(jQuery(this).val());
                var remainingchar = maxchar - (cnt + regCharLen);
                if(remainingchar < 0){
                    jQuery(this).val(jQuery(this).val().slice(0, (maxchar-regCharLen)));
                } else{
                }
            });
    }
    
</script>
