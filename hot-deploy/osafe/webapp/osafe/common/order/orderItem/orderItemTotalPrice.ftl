<li class="${request.getAttribute("attributeClass")!}">
        <div>
         <label>${uiLabelMap.CartItemPriceTotalCaption}</label>
         <span><@ofbizCurrency amount=localOrderReadHelper.getOrderItemSubTotal(orderItem,localOrderReadHelper.getAdjustments()) rounding=globalContext.currencyRounding isoCode=currencyUom/></span>
        </div>
</li>