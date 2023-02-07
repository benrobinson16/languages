using System;
using System.Text.Json;
using System.Text.Json.Serialization;
using Languages.ApiModels;

public class DateConverter : JsonConverter<DateTime>
{
    // Provide date conversion so that the correct ISO format is used.
    public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        string? str = reader.GetString();
        if (typeToConvert == typeof(DateTime) && str != null)
        {
            return DateTime.Parse(str);
        }
        else
        {
            throw new LanguagesInternalError();
        }
    }

    // Provide date conversion so that the correct ISO format is used.
    public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
    {
        writer.WriteStringValue(
            value
                .ToUniversalTime()
                .ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ssZ")
        );
    }
}
