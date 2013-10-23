<div class="${request.getAttribute("attributeClass")!}">
  <a href="<@ofbizUrl>EcommerceOrder.pdf?orderId=${completedOrderId!}</@ofbizUrl>" target="${uiLabelMap.ExportToPDFLabel}" class="standardBtn action" >
    <span>${uiLabelMap.ExportToPDFLabel}</span>
  </a>
</div>