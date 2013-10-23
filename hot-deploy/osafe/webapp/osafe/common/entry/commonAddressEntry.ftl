<script type="text/javascript">
    jQuery(document).ready(function () {
  		//Check if country is available according to DIV sequencing strategy
  		//If NOT we need to add a hidden jquery field to handle processing on the back end and jquery getPostalAdress method (formEntryJS.ftl)
  		//In this case Country is set to system parameter COUNTRY_DEFAULT
	  	if (jQuery('#js_${fieldPurpose?if_exists}_ADDRESS_ENTRY').length)
	  	{
	  		if (jQuery('#js_${fieldPurpose?if_exists}_COUNTRY').length)
	  		{
	  			//Country will be processed as normal
	  		}
	  		else
	  		{
	  			//When only one country is supported (Country Div is hidden or Drop Down is not displayed)
	  			<#assign defaultCountry = Static["com.osafe.util.Util"].getProductStoreParm(request,"COUNTRY_DEFAULT")!"USA"/> 
	      		var defaultCountryValue = "${defaultCountry!"USA"}";
	  			jQuery('<input>').attr({
				    type: 'hidden',
				    id: 'js_${fieldPurpose?if_exists}_COUNTRY',
				    name: '${fieldPurpose?if_exists}_COUNTRY',
				    value: ''+defaultCountryValue+''
				}).appendTo('#js_${fieldPurpose?if_exists}_ADDRESS_ENTRY');
				jQuery('#js_${fieldPurpose?if_exists}_COUNTRY').val(defaultCountryValue);
				updateShippingOption('N');
	  		}
	  	}
	  	
	  	//When country is changed get the list of available state/province geo. 
        if (jQuery('#js_${fieldPurpose?if_exists}_COUNTRY')) 
        {
            if(!jQuery('#${fieldPurpose?if_exists}_STATE_LIST_FIELD').length) 
            {
                getAssociatedStateList('js_${fieldPurpose?if_exists}_COUNTRY', 'js_${fieldPurpose?if_exists}_STATE', 'advice-required-${fieldPurpose?if_exists}_STATE', '${fieldPurpose?if_exists}_STATES');
            }
            getAddressFormat("${fieldPurpose?if_exists}");
            jQuery('#js_${fieldPurpose?if_exists}_COUNTRY').change(function()
            {
                getAssociatedStateList('js_${fieldPurpose?if_exists}_COUNTRY', 'js_${fieldPurpose?if_exists}_STATE', 'advice-required-${fieldPurpose?if_exists}_STATE', '${fieldPurpose?if_exists}_STATES');
                getAddressFormat("${fieldPurpose?if_exists}");
            });
        }
    });
</script>
<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#if fieldPurpose?has_content && context.get(fieldPurpose+"PostalAddress")?has_content>
  <#assign postalAddressData = context.get(fieldPurpose+"PostalAddress") />
</#if>
<#if postalAddressData?has_content>
    <#assign postalAddressContactMechId = postalAddressData.contactMechId!"" />
</#if>
<#if !showAddressEntryBoxHeading?has_content>
    <#assign showAddressEntryBoxHeading = "Y"/>
</#if>
<#if showAddressEntryBoxHeading == "Y">
    <h3>${addressEntryBoxHeading!"Address"}</h3>
</#if>
<#if addressEntryInfo?exists && addressEntryInfo?has_content>
   <p class="instructions">${addressEntryInfo!}</p>
</#if>
<#if addressInstructionsInfo?exists && addressInstructionsInfo?has_content>
     <p class="instructions">${StringUtil.wrapString(addressInstructionsInfo!"")}</p>
</#if>

<input type="hidden" id="${fieldPurpose?if_exists}AddressContactMechId" name="${fieldPurpose?if_exists}AddressContactMechId" value="${postalAddressContactMechId!""}"/>
<input type="hidden" id="${fieldPurpose?if_exists}HomePhoneContactMechId" name="${fieldPurpose?if_exists}HomePhoneContactMechId" value="${telecomHomeNoContactMechId!""}"/>
<input type="hidden" id="${fieldPurpose?if_exists}MobilePhoneContactMechId" name="${fieldPurpose?if_exists}MobilePhoneContactMechId" value="${telecomMobileNoContactMechId!""}"/>
<input type="hidden" id="${fieldPurpose?if_exists}_ADDRESS_ALLOW_SOL" name="${fieldPurpose?if_exists}_ADDRESS_ALLOW_SOL" value="N"/>
<#if isShipping?has_content && isShipping == "Y">
    <#if (errorMessage?has_content || errorMessageList?has_content) && !requestParameters.isSameAsBilling?has_content>
        <#assign isSameAsBilling = "N" />
    </#if>
    <div class="entry addressCheckbox">
        <label for="isSameAsBilling">${uiLabelMap.SameAsBillingCaption}</label>
        <input type="checkbox" class="checkbox" name="isSameAsBilling" id="js_isSameAsBilling" value="Y" <#if isSameAsBilling?has_content && isSameAsBilling == "Y">checked</#if> />
    </div>
    <div class="addressSection">
    <div id="js_${fieldPurpose?if_exists}_AddressSection">
</#if>
<div>
    <@fieldErrors fieldName="${fieldPurpose?if_exists}_ADDRESS_ERROR"/>
</div>
<!-- seelct any address -->
<#if showAddressSelection?has_content && showAddressSelection == "Y">
    <#if fieldPurpose?has_content && context.get(fieldPurpose+"ContactMechList")?has_content>
      <#assign contactMechList = context.get(fieldPurpose+"ContactMechList") />
    </#if>
    <#if contactMechList?has_content>
        <div class="entry addressSelection">
          <label for="${fieldPurpose?if_exists}_ADDRESSES">${uiLabelMap.SelectAddressCaption}</label>
          <#assign shoppingCart = Static["org.ofbiz.order.shoppingcart.ShoppingCartEvents"].getCartObject(request) />
          <#assign  selectedAddress = parameters.get(fieldPurpose+"_SELECT_ADDRESS")!postalAddressContactMechId!""/>
          <#list contactMechList as contactMech>
              <#if contactMech.contactMechTypeId?if_exists = "POSTAL_ADDRESS">
                  <#assign postalAddress=contactMech.getRelatedOneCache("PostalAddress")!"">
                  <#if postalAddress?has_content>
                      <input type="radio" class="${fieldPurpose?if_exists}_SELECT_ADDRESS" name="${fieldPurpose?if_exists}_SELECT_ADDRESS" value="${postalAddress.contactMechId!}" onchange="javascript:getPostalAddress('${postalAddress.contactMechId!}', '${fieldPurpose?if_exists}');"<#if selectedAddress == postalAddress.contactMechId >checked="checked"</#if>/>
                      <span class="radioOptionText"><#if postalAddress.attnName?has_content>${postalAddress.attnName!}<#else>${postalAddress.address1!}</#if></span>
                  </#if>
              </#if>
          </#list>
          <a href="javascript:submitCheckoutForm(document.${formName!}, 'NA', '${fieldPurpose?if_exists}_LOCATION');" class="standardBtn action">${uiLabelMap.AddAddressBtn}</a>
        </div>
    <#else>
        <div class="entry addressSelection">
          <label for="${fieldPurpose?if_exists}_ADDRESSES">${uiLabelMap.SelectAddressCaption}</label>
          <a href="javascript:submitCheckoutForm(document.${formName!}, 'NA', '${fieldPurpose?if_exists}_LOCATION');" class="standardBtn action">${uiLabelMap.AddAddressBtn}</a>
        </div>
    </#if>
    <@fieldErrors fieldName="${fieldPurpose?if_exists}_SELECT_ADDRESS"/>
</#if>
<!-- address common field entry -->
${screens.render("component://osafe/widget/EcommerceDivScreens.xml#addressInfoDivSequence")}
<#if isShipping?has_content && isShipping == "Y">
    </div>
    </div>
</#if>