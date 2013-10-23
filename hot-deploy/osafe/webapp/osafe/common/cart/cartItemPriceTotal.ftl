<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.CartItemPriceTotalCaption}</label>
    <span><@ofbizCurrency amount=itemSubTotal isoCode=currencyUom rounding=globalContext.currencyRounding/></span> 
  </div>
</li>

