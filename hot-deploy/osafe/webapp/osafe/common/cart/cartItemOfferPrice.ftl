<li class="${request.getAttribute("attributeClass")!}">
  <div>
<#if (offerPriceVisible?has_content) && offerPriceVisible == "Y" >
  <#if offerPrice?exists && offerPrice?has_content>
	    <label>${uiLabelMap.CartItemOfferPriceCaption}</label>
	    <span><@ofbizCurrency amount=offerPrice isoCode=currencyUom rounding=globalContext.currencyRounding/></span>
  </#if>
</#if>
  </div>
</li>
