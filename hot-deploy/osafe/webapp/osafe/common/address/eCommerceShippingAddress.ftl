<script type="text/javascript">
//<![CDATA[
/**
* Returns the value of the selected radio button in the radio group, null if
* none are selected, and false if the button group doesn't exist
*
* @param {radio Object} or {radio id} el
* OR
* @param {form Object} or {form id} el
* @param {radio group name} radioGroup
*/
function $RF(el, radioGroup) {
    if($(el).type && $(el).type.toLowerCase() == 'radio') {
        var radioGroup = $(el).name;
        var el = $(el).form;
    } else if ($(el).tagName.toLowerCase() != 'form') {
        return false;
    }

    var checked = $(el).getInputs('radio', radioGroup).find(
        function(re) {return re.checked;}
    );
    return (checked) ? $F(checked) : null;
}
function submitForm(form, mode, value) {
    if (mode == "DN") {
        // done action; checkout
        form.action="<@ofbizUrl>${doneAction!"multiPageCheckoutOptions"}</@ofbizUrl>";
        form.submit();
    } else if (mode == "NA") {
        // new address
        form.action="<@ofbizUrl>${osafeEditRequestName!""}?preContactMechTypeId=POSTAL_ADDRESS&contactMechPurposeTypeId=SHIPPING_LOCATION&DONE_PAGE=${donePage!""}</@ofbizUrl>";
        form.submit();
    } else if (mode == "EA") {
        // edit address
        form.contactMechId.value = value;
        form.action="<@ofbizUrl>${osafeEditRequestName!""}?DONE_PAGE=${donePage!""}</@ofbizUrl>";
        form.submit();
    } else if (mode == "DE") {
        // delete address;
        form.contactMechId.value = value;
        displayDialogBox('${dialogPurpose!}');
    }
}

function toggleBillingAccount(box) {
    var amountName = box.value + "_amount";
    box.checked = true;
    box.form.elements[amountName].disabled = false;

    for (var i = 0; i < box.form.elements[box.name].length; i++) {
        if (!box.form.elements[box.name][i].checked) {
            box.form.elements[box.form.elements[box.name][i].value + "_amount"].disabled = true;
        }
    }
}

//]]>
</script>
<#assign cart = shoppingCart?if_exists/>
<form method="post" id="checkoutInfoForm" name="checkoutInfoForm" >
<input type="hidden" id="checkoutpage" name="checkoutpage" value="shippingaddress"/>
<input type="hidden" id="osafeFormRequestName" name="osafeFormRequestName" value="${osafeFormRequestName}"/>
<input type="hidden" id="contactMechId" name="contactMechId"/>
<div class="shippingAddress">
    <#assign shoppingCartSize = cart.items().size()>
    <#if !addressBookInstructions?has_content>
        <#assign addressBookInstructions = Static["org.ofbiz.base.util.UtilProperties"].getMessage("OSafeUiLabels", "ShippingAddressInstructionsInfo", Static["org.ofbiz.base.util.UtilMisc"].toMap("shoppingCartSize",shoppingCartSize), locale)>
    </#if>
    <p class="instructions">${StringUtil.wrapString(addressBookInstructions?if_exists)}</p>
    <div class="addressContainer">
	    <#-- List of addresses available -->
	    <#if addressContactMechList?has_content>
	      <div class="boxList addressBookList">
	         <#list addressContactMechList as shippingContactMech>
	           <#assign shippingAddress = shippingContactMech.getRelatedOneCache("PostalAddress")>
	           <input type="hidden" id="shipping_contact_mech_id${shippingContactMech_index}"  name="shipping_contact_mech_id" value="${shippingAddress.contactMechId}"/>
	           <#assign checkThisAddress = (shippingContactMech_index == 0 && !cart.getShippingContactMechId()?has_content) || (cart.getShippingContactMechId()?default("") == shippingAddress.contactMechId)/>
	           <div class="boxListItemGrid addressBookItem">
	             <div class="displayBox address">
		              <h3>${shippingAddress.attnName!shippingAddress.address1!""}</h3>
	                  <ul class="displayList address addressOverflow">
					       <#if shippingAddress.toName?has_content && shippingAddress.toName.trim()?has_content>
					         <li><div><span>${shippingAddress.toName}</span></div></li>
					       </#if>
					       <#if shippingAddress.address1?has_content>
					         <li><div><span>${shippingAddress.address1}</span></div></li>
					       </#if>
					       <#if shippingAddress.address2?has_content>
					        <li><div><span>${shippingAddress.address2}</span></div></li>
					       </#if>
					       <#if shippingAddress.address3?has_content>
					        <li><div><span>${shippingAddress.address3}</span></div></li>
					       </#if>
					       <li>
					         <div>
						         <#if shippingAddress.city?has_content  && shippingAddress.city != '_NA_'>
						          	<span>${shippingAddress.city!}, </span>
						         </#if>
						         <#if shippingAddress.stateProvinceGeoId?has_content && shippingAddress.stateProvinceGeoId != '_NA_'>
						          	<span>${shippingAddress.stateProvinceGeoId}</span>
						         </#if>
						         <#if shippingAddress.postalCode?has_content && shippingAddress.postalCode != '_NA_'>
						          	<span>${shippingAddress.postalCode} </span>
						         </#if>
						         <#if shippingAddress.countryGeoId?has_content>
						          	<span>${shippingAddress.countryGeoId}</span>
						         </#if>
					        </div>
					       </li>
	                  </ul>
	                  <div class="container button">
		                   <a href="javascript:submitForm(document.checkoutInfoForm, 'EA', ${shippingAddress.contactMechId});" class="standardBtn update">${uiLabelMap.UpdateAddressBtn}</a>
		                   <#if showDelete?has_content && showDelete=="Y">
		                       <#if firstBillingContactMechId?if_exists != shippingContactMech.contactMechId>
		                        <a href="javascript:submitForm(document.checkoutInfoForm, 'DE', ${shippingAddress.contactMechId});" class="standardBtn delete">${uiLabelMap.DeleteBtn}</a>
		                       </#if>
		                   </#if>
	                  </div>
	             </div>
	           </div>
	          </#list>
	     </div>
	    </#if>
	    <div class="container button">
	        <#if backAction?exists && backAction?has_content>
	          <a class="standardBtn negative" href="<@ofbizUrl>${backAction!}</@ofbizUrl>">${uiLabelMap.CommonBack}</a>
	        </#if>
	        <a href="javascript:submitForm(document.checkoutInfoForm, 'NA', '');" class="standardBtn action">${uiLabelMap.AddAddressBtn}</a>
	    </div>
   </div>
</div>
</form>
