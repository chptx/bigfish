<li class="${request.getAttribute("attributeClass")!}">
    <div>
      <label>${uiLabelMap.ReOrderCheckBoxCaption}</label>
      <#if productBuyable == 'true'>
        <input type="checkbox" class="add_multi_product_id" name="add_multi_product_id_${idx}" id="js_add_multi_product_id_${idx}" value="${productId!}"/>
      <#else>
        <span>${uiLabelMap.ProductNoLongerAvailableInfo}</span>
      </#if> 
    </div>
</li>