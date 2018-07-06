package com.pinterest.secor.parser;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pinterest.secor.common.SecorConfig;
import com.pinterest.secor.message.Message;
import com.pinterest.secor.parser.JsonMessageParser;
import com.pinterest.secor.parser.MessageParser;
import org.apache.commons.lang.ArrayUtils;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class PartnerMessageParser extends JsonMessageParser {
    ObjectMapper mapper = new ObjectMapper();

    public PartnerMessageParser(SecorConfig config) {
        super(config);
    }

    @Override
    public String[] extractPartitions(Message message) throws Exception {
        String[] toAppend = super.extractPartitions(message);
        Map<String, Object> messageJson = mapper.readValue(message.getPayload(), Map.class);
        String partnerName = (String) messageJson.get("partner");

        return (String[]) ArrayUtils.addAll(new String[]{partnerName}, toAppend);
    }
}
