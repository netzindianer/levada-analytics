# Levada Analytics

Levada Analytics is a client-side event layer for websites. It works as a pub/sub system — the page publishes structured events (page views, user data, clicks), and you subscribe to the ones you need and forward the data to your analytics tool.

## Quick start

```js
LevadaAnalytics.Subscribe('Page', (data) => {
    console.log('Page view:', data.url);
});
```

Each `Subscribe` call registers a listener that fires when a given event is published.

## Built-in events

Levada Analytics publishes events in a defined order. Two events are special and always available:

1. **`User`** — published first. Contains data about the current user.
2. **`Page`** — published right after `User`. Contains data about the current page.

This order is guaranteed — a `Page` listener can safely rely on user data already being available because `User` has already been published. Both fire after `DOMContentLoaded` — once the browser has finished parsing the full HTML document.

Other events can fire on user interaction (e.g., a button click).

### Accessing current data

You don't need to subscribe to read current data. The latest objects are available directly:

```js
LevadaAnalytics.User  // current User object
LevadaAnalytics.Page  // current Page object
```

## Subscribing to events

### Subscribe

Registers a listener for a specific event:

```js
LevadaAnalytics.Subscribe('Page', (data) => {
    dataLayer.push({
        event: 'page_view',
        page_title: data.title,
        page_url: data.url,
    });
});
```

### SubscribeAll

Registers a listener for every event. The callback receives the event name as the first argument:

```js
LevadaAnalytics.SubscribeAll((name, data) => {
    console.log(`Event: ${name}`, data);
});
```

## Custom events

Beyond `User` and `Page`, a page can publish any custom events. Here's a `Click` event with data about a clicked link:

```js
LevadaAnalytics.Subscribe('Click', (data) => {
    dataLayer.push({
        event: 'click',
        link_url: data.url,
        link_text: data.text,
    });
});
```

An e-commerce example — product added to cart:

```js
LevadaAnalytics.Subscribe('AddToCart', (data) => {
    dataLayer.push({
        event: 'add_to_cart',
        currency: data.currency,
        value: data.price,
        items: [{
            item_id: data.productId,
            item_name: data.name,
            price: data.price,
            quantity: data.quantity,
        }],
    });
});
```

## Debug

Levada Analytics includes built-in debugging tools available on the `Debug` object.

### Logging events

Enables logging every published event to the DevTools console:

```js
LevadaAnalytics.Debug.Log(true);
```

### Listing available events

Displays the names of all events registered on the page:

```js
LevadaAnalytics.Debug.Names();
```

### Manually firing events

Fires a single event by name (useful for testing listeners):

```js
LevadaAnalytics.Debug.Event('Page');
```

Fires all events registered on the page:

```js
LevadaAnalytics.Debug.Events();
```

### Muting listeners

Prevents all listener callbacks from executing. Events are still published, but callbacks are skipped. Pass `false` to re-enable:

```js
LevadaAnalytics.Debug.Mute(true);   // listeners stop firing
LevadaAnalytics.Debug.Mute(false);  // listeners fire again
```

## Example implementation

A full integration example with Google Tag Manager (dataLayer). Shows event object structures and a typical data mapping approach.

### User object

```js
// Example User object
{
    id: 'usr_28a4f1c',
    type: 'returning',        // 'new' | 'returning'
    isLoggedIn: true,
}
```

### Page object

```js
// Example Page object
{
    title: 'Products — Men\'s shoes',
    url: '/products/mens-shoes',
    type: 'category',         // 'home' | 'category' | 'product' | 'article' | ...
    breadcrumbs: ['Home', 'Products', 'Men\'s shoes'],
}
```

### AddToCart object

```js
// Example AddToCart object
{
    productId: 'SKU-1042',
    name: 'Nike Air Max 90',
    price: 549.99,
    currency: 'PLN',
    quantity: 1,
    category: 'Men\'s shoes',
}
```

### Full example

```js
// User — always published first
LevadaAnalytics.Subscribe('User', (data) => {
    dataLayer.push({
        user_id: data.id,
        user_type: data.type,
        user_logged_in: data.isLoggedIn,
    });
});

// Page — published right after User
LevadaAnalytics.Subscribe('Page', (data) => {
    dataLayer.push({
        event: 'page_view',
        page_title: data.title,
        page_url: data.url,
        page_type: data.type,
    });
});

// AddToCart — e-commerce event
LevadaAnalytics.Subscribe('AddToCart', (data) => {
    dataLayer.push({
        event: 'add_to_cart',
        currency: data.currency,
        value: data.price,
        items: [{
            item_id: data.productId,
            item_name: data.name,
            price: data.price,
            quantity: data.quantity,
        }],
    });
});
```
