<li class="${request.getAttribute("attributeClass")!}">
  <#if DELIVERY_INFO?exists && DELIVERY_INFO?has_content>
    <div>
       <div class="displayBox">
         <h3>${uiLabelMap.PDPDeliveryInfoHeading}</h3>
         <p><@renderContentAsText contentId="${DELIVERY_INFO}" ignoreTemplate="true"/></p>
       </div>
    </div>
  </#if>
</li>
