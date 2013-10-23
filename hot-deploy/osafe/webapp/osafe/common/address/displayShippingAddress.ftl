<#if shippingAddress?has_content>
     <#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
      <div class="displayBox">
	       <h3>${uiLabelMap.ShippingAddressHeading}</h3>
	       <ul class="displayList address">
	        <#if shippingAddress.toName?has_content>
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
      </div>
</#if>