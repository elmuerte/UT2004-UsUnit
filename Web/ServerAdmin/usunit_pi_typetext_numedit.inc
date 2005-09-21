<input type="text" name="<%PI.SettingName%>" value="<%PI.value%>" class="text" size="<%PI.size%>" maxlength="<%PI.maxlength%>" id="<%PI.ID%>" onkeydown="EditOnKeyDown('<%PI.ID%>', event);" onkeypress="return EditOnKeyPress('<%PI.ID%>', event);" />
<button type="button" onmousedown="EditUp('<%PI.ID%>');">+</button><button type="button" onmousedown="EditDown('<%PI.ID%>')">-</button>
<script type="text/javascript">SetEditRange('<%PI.ID%>', '<%PI.range%>');</script>
<br />