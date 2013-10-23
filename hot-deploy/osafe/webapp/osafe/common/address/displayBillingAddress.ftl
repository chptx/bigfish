<#if billingAddress?has_content>
   <#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
	<div class="displayBox">
      <h3>${uiLabelMap.BillingAddressTitle}</h3>
      <ul class="displayList address">
       <#if billingAddress.toName?has_content>
         <li><div><span>${billingAddress.toName}</span></div></li>
        </#if>
       <#if billingAddress.address1?has_content>
        <li><div><span>${billingAddress.address1}</span></div></li>
       </#if>
       <#if billingAddress.address2?has_content>
        <li><div><span>${billingAddress.address2}</span></div></li>
       </#if>
       <#if billingAddress.address3?has_content>
        <li><div><span>${billingAddress.address3}</span></div></li>
       </#if>
       <li>
        <div>
         <#if billingAddress.city?has_content  && billingAddress.city != '_NA_'>
          <span>${billingAddress.city!}, </span>
         </#if>
         <#if billingAddress.stateProvinceGeoId?has_content && billingAddress.stateProvinceGeoId != '_NA_'>
          <span>${billingAddress.stateProvinceGeoId}</span>
         </#if>
         <#if billingAddress.postalCode?has_content && billingAddress.postalCode != '_NA_'>
          <span>${billingAddress.postalCode} </span>
         </#if>
         <#if billingAddress.countryGeoId?has_content>
          <span>${billingAddress.countryGeoId}</span>
         </#if>
        </div>
        </li>
      </ul>
    </div>
</#if>