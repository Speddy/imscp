
<script type="text/javascript">
	/* <![CDATA[ */
	$(document).ready(function () {
		if (!$('#forwardAccount').is(':checked') && $('#forwardList').val() == '') {
			$('#forwardList').attr('disabled', true);
		}

		$('#forwardAccount').change(function () {
			if ($(this).is(':checked')) {
				$('#forwardList').removeAttr('disabled');
			} else {
				$('#forwardList').attr('disabled', true).val('');
			}
		});
	});
	/* ]]> */
</script>

<form name="editFrm" method="post" action="mail_edit.php?id={MAIL_ID_VAL}">
	<table class="firstColFixed">
		<thead>
		<tr>
			<th colspan="2"><span style="vertical-align: middle">{TR_MAIL_ACCOUNT} : {MAIL_ADDRESS_VAL}</span></th>
		</tr>
		</thead>
		<tbody>
		<!-- BDP: password_frm -->
		<tr>
			<td><label for="password">{TR_PASSWORD}</label></td>
			<td><input name="password" id="password" type="password" value="" autocomplete="off"/></td>
		</tr>
		<tr>
			<td><label for="passwordConfirmation">{TR_PASSWORD_CONFIRMATION}</label></td>
			<td>
				<input name="passwordConfirmation" id="passwordConfirmation" type="password" value=""
					   autocomplete="off"/>
			</td>
		</tr>
		<tr>
			<td><label for="forwardAccount">{TR_FORWARD_ACCOUNT}</label></td>
			<td><input name="forwardAccount" id="forwardAccount" type="checkbox"{FORWARD_ACCOUNT_CHECKED}/></td>
		</tr>
		<!-- EDP: password_frm -->
		<tr>
			<td>
				<label for="forwardList">{TR_FORWARD_TO}</label>
				<span class="icon i_help" id="fwd_help" title="{TR_FWD_HELP}"></span>
			</td>
			<td><textarea name="forwardList" id="forwardList">{FORWARD_LIST_VAL}</textarea></td>
		</tr>
		</tbody>
	</table>

	<div class="buttons">
		<input name="submit" type="submit" value="{TR_UPDATE}"/>
		<a class ="link_as_button" href="mail_accounts.php">{TR_CANCEL}</a>
	</div>
</form>
