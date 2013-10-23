<#if isFinishedGood>
<li class="${request.getAttribute("attributeClass")!}">
 <div>
  <label>${uiLabelMap.QuantityLabel}</label>
  <#if inStock>
  	<input type="hidden" name="qtyInCart_${plpProductId!}" id="js_qtyInCart_${plpProductId!}_${uiSequenceScreen!}" value="${plpItemQtyInCart!}"/>
    <input type="text" class="quantity plpInStock" size="5" name="quantity_${plpProductId!}" id="js_quantity_${plpProductId!}_${uiSequenceScreen!}" value="" maxlength="5"/>
  <#else>
     <input type="text" class="quantity plpOutOfStock" size="5" name="quantity_${plpProductId!}" id="js_quantity_${plpProductId!}_${uiSequenceScreen!}" value="" maxlength="5" disabled="disabled"/>
  </#if>
 </div>
</li>   
</#if>




