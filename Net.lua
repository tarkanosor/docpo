---@diagnostic disable: missing-return
--- Infinity Net namespace
---@class Infinity.Net
Infinity.Net = {}

---@param data ByteBuffer
function Infinity.Net.Send(data)
end

---@param data ByteBuffer
function Infinity.Net.Receive(data)
end

--- Data returned from HTTP requests.
---@class HttpResponseData
---@field status number           -- HTTP status code. -1 indicates an error/no response.
---@field body string             -- The response body as a string.
---@field headers table<string, string>  -- A table mapping header names to their values.

--- Wrapper for an asynchronous HTTP request.
---@class AsyncHttpRequest
---@field is_complete fun(self: AsyncHttpRequest): boolean  -- Returns true if the HTTP request has finished.
---@field get_result fun(self: AsyncHttpRequest): HttpResponseData      -- Returns the HttpResponseData as a Lua table when complete.

--- HTTP Client for performing synchronous and asynchronous HTTP requests.
---@class HttpClient
---@field new fun(host: string, port: number): HttpClient  -- Creates a new HttpClient instance.
---@field get fun(self: HttpClient, path: string): table     -- Performs a synchronous GET request and returns a table containing the response.
---@field post fun(self: HttpClient, path: string, body: string, content_type: string): HttpResponseData
---@field put fun(self: HttpClient, path: string, body: string, content_type: string): HttpResponseData
---@field patch fun(self: HttpClient, path: string, body: string, content_type: string): HttpResponseData
---@field async_get fun(self: HttpClient, path: string): AsyncHttpRequest  -- Begins an asynchronous GET request and returns an AsyncHttpRequest.
---@field async_post fun(self: HttpClient, path: string, body: string, content_type: string): AsyncHttpRequest
---@field async_put fun(self: HttpClient, path: string, body: string, content_type: string): AsyncHttpRequest
---@field async_patch fun(self: HttpClient, path: string, body: string, content_type: string): AsyncHttpRequest
---@return HttpClient
function HttpClient(host, port)
end
