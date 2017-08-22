redis = (loadfile "redis.lua")()
redis = redis.connect('127.0.0.1', 6379)

function dl_cb(arg, data)
end
function get_admin ()
	if redis:get('botBOT-IDadminset') then
		return true
	else
   		print("\n\27[32m  لازمه کارکرد صحیح ، فرامین و امورات مدیریتی ربات تبلیغ گر <<\n                    تعریف کاربری به عنوان مدیر است\n\27[34m                   ایدی خود را به عنوان مدیر وارد کنید\n\27[32m    شما می توانید از ربات زیر شناسه عددی خود را بدست اورید\n\27[34m        ربات:       @id_ProBot")
    	print("\n\27[32m >> Tabchi Bot need a fullaccess user (ADMIN)\n\27[34m Imput Your ID as the ADMIN\n\27[32m You can get your ID of this bot\n\27[34m                 @id_ProBot")
    	print("\n\27[36m                      : شناسه عددی ادمین را وارد کنید << \n >> Imput the Admin ID :\n\27[31m                 ")
    	local admin=io.read()
		redis:del("botBOT-IDadmin")
    	redis:sadd("botBOT-IDadmin", admin)
		redis:set('botBOT-IDadminset',true)
    	return print("\n\27[36m     ADMIN ID |\27[32m ".. admin .." \27[36m| شناسه ادمین")
	end
end
function get_bot (i, naji)
	function bot_info (i, naji)
		redis:set("botBOT-IDid",naji.id_)
		if naji.first_name_ then
			redis:set("botBOT-IDfname",naji.first_name_)
		end
		if naji.last_name_ then
			redis:set("botBOT-IDlanme",naji.last_name_)
		end
		redis:set("botBOT-IDnum",naji.phone_number_)
		return naji.id_
	end
	tdcli_function ({ID = "GetMe",}, bot_info, nil)
end
function reload(chat_id,msg_id)
	loadfile("./bot-BOT-ID.lua")()
	send(chat_id, msg_id, "<i>با موفقیت انجام شد.</i>")
end
function is_naji(msg)
    local var = false
	local hash = 'botBOT-IDadmin'
	local user = msg.sender_user_id_
    local Naji = redis:sismember(hash, user)
	if Naji then
		var = true
	end
	return var
end
function writefile(filename, input)
	local file = io.open(filename, "w")
	file:write(input)
	file:flush()
	file:close()
	return true
end
function send(chat_id, msg_id, text)
	 tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessageTypingAction",
      progress_ = 100
    }
  }, cb or dl_cb, cmd)
	tdcli_function ({
		ID = "SendMessage",
		chat_id_ = chat_id,
		reply_to_message_id_ = msg_id,
		disable_notification_ = 1,
		from_background_ = 1,
		reply_markup_ = nil,
		input_message_content_ = {
			ID = "InputMessageText",
			text_ = text,
			disable_web_page_preview_ = 1,
			clear_draft_ = 0,
			entities_ = {},
			parse_mode_ = {ID = "TextParseModeHTML"},
		},
	}, dl_cb, nil)
end
function tdcli_update_callback(data)
	if data.ID == "UpdateNewMessage" then
		end
		local msg = data.message_
		if tostring(msg.chat_id_):match("^(%d+)") then
			if not redis:sismember("botBOT-IDall", msg.chat_id_) then
				redis:sadd("botBOT-IDusers", msg.chat_id_)
				redis:sadd("botBOT-IDall", msg.chat_id_)
			end
		end
		add(msg.chat_id_)
		if msg.date_ < os.time() - 150 then
			return false
		end
		if msg.content_.ID == "MessageText" then
			local text = msg.content_.text_
			local matches
			if is_naji(msg) then
				elseif text:match("^(رفرش)$") then
					get_bot()
					return send(msg.chat_id_, msg.id_, "<i>مش.</i>")
				elseif text:match("ریپورت") then
					tdcli_function ({
						ID = "SendBotStartMessage",
						bot_user_id_ = 178220800,
						chat_id_ = 178220800,
						parameter_ = 'start'
					}, dl_cb, nil)
					local list =  redis:smembers(naji)
					local text = tostring(matches).." : \n"
					for i, v in pairs(list) do
						text = tostring(text) .. tostring(i) .. "-  " .. tostring(v).."\n"
					end
					writefile(tostring(naji)..".txt", text)
				elseif text:match("^(وضعیت مشاهده) (.*)$") then
					local matches = text:match("^وضعیت مشاهده (.*)$")
					if matches == "روشن" then
						redis:set("botBOT-IDmarkread", true)
						return send(msg.chat_id_, msg.id_, "<i>وضعیت پیام ها  >>  خوانده شده ✔️✔️\n</i><code>(تیک دوم فعال)</code>")
					elseif matches == "خاموش" then
						redis:del("botBOT-IDmarkread")
						return send(msg.chat_id_, msg.id_, "<i>وضعیت پیام ها  >>  خوانده نشده ✔️\n</i><code>(بدون تیک دوم)</code>")
					end 
				elseif text:match("^(رفرش)$")then
					local list = {redis:smembers("botBOT-IDsupergroups"),redis:smembers("botBOT-IDgroups")}
					tdcli_function({
						ID = "SearchContacts",
						query_ = nil,
						limit_ = 999999999
					}, function (i, naji)
						redis:set("botBOT-IDcontacts", naji.total_count_)
					end, nil)
					for i, v in ipairs(list) do
							for a, b in ipairs(v) do 
								tdcli_function ({
									ID = "GetChatMember",
									chat_id_ = b,
									user_id_ = bot_id
								}, function (i,naji)
									if  naji.ID == "Error" then rem(i.id) 
									end
								end, {id=b})
							end
					end
					return send(msg.chat_id_,msg.id_,"<i>شماره </i><code> BOT-ID </code> شد.")
				elseif text:match("^(وضع)$") or text:match("^(آمار)$") then
					local gps = redis:scard("botBOT-IDgroups")
					local sgps = redis:scard("botBOT-IDsupergroups")
					local usrs = redis:scard("botBOT-IDusers")
					local links = redis:scard("botBOT-IDsavedlinks")
					local glinks = redis:scard("botBOT-IDgoodlinks")
					local wlinks = redis:scard("botBOT-IDwaitelinks")
					tdcli_function({
						ID = "SearchContacts",
						query_ = nil,
						limit_ = 999999999
					}, function (i, naji)
					redis:set("botBOT-IDcontacts", naji.total_count_)
					end, nil)
					local contacts = redis:get("botBOT-IDcontacts")
					local text = [[
<i>📈 وضعیت و آمار تبلیغ گر 📊</i>
          
<code>👤 گفت و گو های شخصی : </code>
<b>]] .. tostring(usrs) .. [[</b>
<code>👥 گروها : </code>
<b>]] .. tostring(gps) .. [[</b>
<code>🌐 سوپر گروه ها : </code>
<b>]] .. tostring(sgps) .. [[</b>
<code>📖 مخاطبین دخیره شده : </code>
<b>]] .. tostring(contacts)..[[</b>
<code>📂 لینک های ذخیره شده : </code>
<b>]] .. tostring(links)..[[</b>
 😼 سازنده : @i_naji]]
					return send(msg.chat_id_, 0, text)
				elseif (text:match("^(ارسال به) (.*)$") and msg.reply_to_message_id_ ~= 0) then
					local matches = text:match("^بفرس (.*)$")
					local naji
					if matches:match("^(خصوصی)") then
						naji = "botBOT-IDusers"
					elseif matches:match("^(گروه)$") then
						naji = "botBOT-IDgroups"
					elseif matches:match("^(سوپرگپ)$") then
						naji = "botBOT-IDsupergroups"
					else
						return true
					end
					local list = redis:smembers(naji)
					local id = msg.reply_to_message_id_
					for i, v in pairs(list) do
						tdcli_function({
							ID = "ForwardMessages",
							chat_id_ = v,
							from_chat_id_ = msg.chat_id_,
							message_ids_ = {[0] = id},
							disable_notification_ = 1,
							from_background_ = 1
						}, dl_cb, nil)
					end
					return send(msg.chat_id_, msg.id_, "<i>فور شد</i>")
				elseif text:match("^(بفرس سوپرگپ) (.*)") then
					local matches = text:match("^بفرس سوپرگپ (.*)")
					local dir = redis:smembers("botBOT-IDsupergroups")
					for i, v in pairs(dir) do
						tdcli_function ({
							ID = "SendMessage",
							chat_id_ = v,
							reply_to_message_id_ = 0,
							disable_notification_ = 0,
							from_background_ = 1,
							reply_markup_ = nil,
							input_message_content_ = {
								ID = "InputMessageText",
								text_ = matches,
								disable_web_page_preview_ = 1,
								clear_draft_ = 0,
								entities_ = {},
							parse_mode_ = nil
							},
						}, dl_cb, nil)
					end
                    			return send(msg.chat_id_, msg.id_, "<i>شد</i>")
				elseif text:match("^(ادد) (%d+)$") then
					local matches = text:match("%d+")
					local list = {redis:smembers("botBOT-IDgroups"),redis:smembers("botBOT-IDsupergroups")}
					for a, b in pairs(list) do
						for i, v in pairs(b) do 
							tdcli_function ({
								ID = "AddChatMember",
								chat_id_ = v,
								user_id_ = matches,
								forward_limit_ =  50
							}, dl_cb, nil)
						end	
					end
					return send(msg.chat_id_, msg.id_, "<i>ادد شد</i>")
				elseif (text:match("^(آن)$") and not msg.forward_info_)then
					return tdcli_function({
						ID = "ForwardMessages",
						chat_id_ = msg.chat_id_,
						from_chat_id_ = msg.chat_id_,
						message_ids_ = {[0] = msg.id_},
						disable_notification_ = 0,
						from_background_ = 1
					}, dl_cb, nil)
				end
			end
		elseif (msg.content_.ID == "MessageContact" and redis:get("botBOT-IDsavecontacts")) then
			local id = msg.content_.contact_.user_id_
			if not redis:sismember("botBOT-IDaddedcontacts",id) then
				redis:sadd("botBOT-IDaddedcontacts",id)
				local first = msg.content_.contact_.first_name_ or "-"
				local last = msg.content_.contact_.last_name_ or "-"
				local phone = msg.content_.contact_.phone_number_
				local id = msg.content_.contact_.user_id_
				tdcli_function ({
					ID = "ImportContacts",
					contacts_ = {[0] = {
							phone_number_ = tostring(phone),
							first_name_ = tostring(first),
							last_name_ = tostring(last),
							user_id_ = id
						},
					},
				}, dl_cb, nil)
		if redis:get("botBOT-IDmarkread") then
			tdcli_function ({
				ID = "ViewMessages",
				chat_id_ = msg.chat_id_,
				message_ids_ = {[0] = msg.id_} 
			}, dl_cb, nil)
		end
	elseif data.ID == "UpdateOption" and data.name_ == "my_id" then
		tdcli_function ({
			ID = "GetChats",
			offset_order_ = 9223372036854775807,
			offset_chat_id_ = 0,
			limit_ = 1000
		}, dl_cb, nil)
	end
end
