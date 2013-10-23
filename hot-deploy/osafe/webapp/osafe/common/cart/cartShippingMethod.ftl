<#if shippingApplies?exists && shippingApplies>
  <li class="${request.getAttribute("attributeClass")!}">
	<div>
	  <label>${uiLabelMap.CartShippingMethodLabel}</label>
	  <span>${chosenShippingMethodDescription!}</span>
	</div>
  </li>
</#if>