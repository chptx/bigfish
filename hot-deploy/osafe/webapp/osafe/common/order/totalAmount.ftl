<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.TotalAmountCaption}</label>
    <span><@ofbizCurrency amount=orderHeader.grandTotal isoCode=orderHeader.currencyUom rounding=globalContext.currencyRounding/></span>
  </div>
</li>