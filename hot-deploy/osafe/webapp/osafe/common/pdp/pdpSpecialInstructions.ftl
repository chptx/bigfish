<li class="${request.getAttribute("attributeClass")!}">
  <#if SPECIALINSTRUCTIONS?exists && SPECIALINSTRUCTIONS?has_content>
    <div>
       <div class="displayBox">
         <h3>${uiLabelMap.PDPSpecialInstructionsHeading}</h3>
         <p><@renderContentAsText contentId="${SPECIALINSTRUCTIONS}" ignoreTemplate="true"/></p>
       </div>
    </div>
  </#if>
</li>
