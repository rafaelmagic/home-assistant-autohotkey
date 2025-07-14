#Requires AutoHotkey v2.0
#Include <JSON>
#Include <passwords>

; CONTROL HOME ASSISTANT (REST API) WITH YOUR KEYBOARD VIA AutoHotkey
; Customized ✨ by Magic of Rafael – www.rafaelmagic.com

;########################################################################
;#############     🔥 Hotkeys (Ctrl+Alt+Key)     ########################
;########################################################################

^!q:: HA.Toggle("light.aqara_light_switch")
^!o:: HA.Toggle("light.aqara_light_switch")
^!p:: HA.Toggle("light.aqara_light_switch")
^!h:: HA.Toggle("light.aqara_light_switch")
^!1:: HA.Unlock("lock.aqara_smart_lock")
^!2:: HA.Lock("lock.aqara_smart_lock")
^!w:: HA.TurnOn("light.aqara_light_switch")
^!e:: HA.TurnOff("light.aqara_light_switch")
^!j:: HA.SendMQTT("light/living_room", "Light is on")
^!t:: HA.SendNotify("Time to walk the dog!", "Reminder", "notify.mobile_app_magic")
^!s:: HA.ActivateScene("scene.relax_evening")
^!x:: HA.RunScript("script.good_night")

^!y:: {
    entity := "light.aqara_light_switch"
    data := HA.GetState(entity)
    MsgBox(IsObject(data) && data.Has("state")
        ? "💡 State of " entity ": " data["state"]
        : "❌ Could not retrieve state.")
}

^!u:: {
    entity := "light.aqara_light_switch"
    data := HA.GetState(entity)
    if !IsObject(data) {
        MsgBox("❌ Could not fetch state.")
        return
    }
    if data.Has("attributes") {
        output := "🔧 Attributes for " entity ":`n`n"
        for k, v in data["attributes"] {
            valStr := IsObject(v) ? JSON.stringify(v) : v
            output .= k ": " valStr "`n"
        }
        MsgBox RTrim(output)
    } else {
        MsgBox("⚠️ No attributes found.")
    }
}

^!k:: {
    entity := "light.aqara_light_switch"
    data := HA.Get("states/" entity)

    try {
        if !IsObject(data)
            throw Error("Response is not a JSON object.")
        jsonFormatted := JSON.stringify(data, , "  ")
        Clipboard := jsonFormatted
        MsgBox("📟 Raw JSON for " entity ":`n`n" RTrim(jsonFormatted))
    } catch Error as e {
        MsgBox("⚠️ Failed to stringify JSON:`n" e.Message)
    }
}

^!i:: {
    entity := "sensor.aqara_temp_humidity_sensor_temperature"
    data := HA.GetState(entity)
    state := (IsObject(data) && data.Has("state")) ? data["state"] : "[unknown]"
    unit := (IsObject(data) && data.Has("attributes") && data["attributes"].Has("unit_of_measurement")) ? data["attributes"]["unit_of_measurement"] : ""
    name := (IsObject(data) && data.Has("attributes") && data["attributes"].Has("friendly_name")) ? data["attributes"]["friendly_name"] : "[no name]"
    unit := RegExReplace(unit, "^(A\s+|[^\°\w]+)")
    MsgBox("📡 " entity "`nState: " state "`nUnit: " unit "`nName: " name)
}

^!z:: MsgBox(HA.IsAPIrunning() ? "✅ API is running." : "❌ API is NOT reachable.")

;########################################################################
;#############     🚀 Home Assistant Class     ##########################
;########################################################################

class HA {
    static Url := "https://myhomeassistanturl.com"
    static ApiKey := HA._ReadTokenFromCredMgr()
    static MaxRetries := 3
    static TimeoutMs := 5000

    static _ReadTokenFromCredMgr() {
        creds := CredRead("AHK_HomeAssistantAPI")
        if !creds {
            MsgBox("❌ Could not read token from Credential Manager.`nPress Ctrl+Alt+C to store it.`nScript will now exit.")
            ExitApp()
        }
        return creds.password
    }

    static IsAPIrunning() {
        resp := this.Get("")
        return IsObject(resp) && resp.Has("message") && resp["message"] == "API running."
    }

    static Toggle(entity) => this._CallWithValidation("toggle", entity)
    static TurnOn(entity) => this._CallWithValidation("turn_on", entity)
    static TurnOff(entity) => this._CallWithValidation("turn_off", entity)
    static Lock(entity) => this._CallWithValidation("lock", entity, "lock")
    static Unlock(entity) => this._CallWithValidation("unlock", entity, "lock")
    static ActivateScene(entity) => this.CallService("scene", "turn_on", { entity_id: entity })
    static RunScript(entity) => this.CallService("script", "turn_on", { entity_id: entity })
    static SendMQTT(topic, payload) => this.CallService("mqtt", "publish", { topic: topic, payload: payload })

    static SendNotify(message, title, fullService) {
        if (fullService == "" || !InStr(fullService, ".")) {
            MsgBox("⚠️ Invalid notify format: " fullService)
            return
        }
        parts := StrSplit(fullService, ".")
        return this.CallService(parts[1], parts[2], { message: message, title: title })
    }

    static Template(info) => this.Post("template", { template: info })

    static GetState(entity, attribute := "") {
        if !this._IsValidEntity(entity)
            return ""
        data := this.Get("states/" entity)
        if (!IsObject(data) || !data.Has("state") || data["state"] == "")
            return ""
        return (attribute && data.Has("attributes") && data["attributes"].Has(attribute))
            ? data["attributes"][attribute]
            : data
    }

    static _CallWithValidation(service, entity, domain := "") {
        if !this._IsValidEntity(entity)
            return
        domain := domain ? domain : StrSplit(entity, ".")[1]
        return this.CallService(domain, service, { entity_id: entity })
    }

    static CallService(domain, service, data := "") {
        retryCount := 0
        while retryCount < this.MaxRetries {
            result := this.Post("services/" domain "/" service, data)
            if (IsObject(result) && (!result.Has("message") || result["message"] != "HTTP error"))
                return result
            retryCount++
            Sleep(1000 * (2 ** (retryCount - 1)))
        }
        MsgBox("❌ CallService failed after " this.MaxRetries " attempts.")
    }

    static Get(endpoint) => this.HTTP("GET", endpoint)
    static Post(endpoint, data := "") => this.HTTP("POST", endpoint, data)

    static HTTP(method, endpoint, data := "") {
        try {
            fullUrl := this.Url "/api/" endpoint
            HTTP := ComObject("WinHttp.WinHttpRequest.5.1")
            HTTP.SetTimeouts(this.TimeoutMs, this.TimeoutMs, this.TimeoutMs, this.TimeoutMs)
            HTTP.Open(method, fullUrl, false)
            HTTP.SetRequestHeader("Authorization", "Bearer " this.ApiKey)
            HTTP.SetRequestHeader("Content-Type", "application/json")
            HTTP.Send(data == "" ? "" : JSON.stringify(data))
            HTTP.WaitForResponse(this.TimeoutMs)

            status := HTTP.Status
            responseText := HTTP.ResponseText

            switch status {
                case 200, 201:
                    return JSON.parse(responseText)
                case 400:
                    MsgBox("⚠️ 400 Bad Request`n" fullUrl)
                case 401:
                    MsgBox("🔒 401 Unauthorized`nCheck your API token.")
                case 404:
                    MsgBox("❌ 404 Not Found`n" fullUrl)
                case 405:
                    MsgBox("🚫 405 Method Not Allowed`n" fullUrl)
                default:
                    MsgBox("❗ HTTP " status "`n`nResponse:`n" responseText)
            }
        } catch Error as e {
            MsgBox("🚨 HTTP Exception:`n" e.Message)
            return { message: "connection error" }
        }
    }

    static _IsValidEntity(entity) {
        if (StrLen(entity) == 0 || !InStr(entity, ".")) {
            MsgBox("⚠️ Invalid entity: " entity)
            return false
        }
        return true
    }
}
