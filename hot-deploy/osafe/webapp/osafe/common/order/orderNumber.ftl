<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.OrderNumberCaption}</label>
    <a href="<@ofbizUrl>eCommerceOrderDetail?orderId=${orderHeader.orderId}</@ofbizUrl>"><span>${orderHeader.orderId}</span></a>
  </div>
</li>